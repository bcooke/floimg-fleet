defmodule FloimgFleet.Seeds do
  @moduledoc """
  Seeding utilities for generating bots from persona definitions.

  Personas are defined in `priv/seeds/personas.json` and represent
  different FloImg user archetypes (product photographer, social marketer, etc.).
  """

  @personas_path "priv/seeds/personas.json"

  @doc """
  Loads all personas from the JSON seed file.

  Returns a map with :personas, :adjectives, and :nouns keys.
  """
  def load_personas do
    path = Application.app_dir(:floimg_fleet, @personas_path)

    path
    |> File.read!()
    |> Jason.decode!()
  end

  @doc """
  Gets a specific persona by ID.

  Returns nil if not found.
  """
  def get_persona(persona_id) do
    data = load_personas()

    Enum.find(data["personas"], fn p -> p["id"] == persona_id end)
  end

  @doc """
  Lists all persona IDs.
  """
  def list_persona_ids do
    data = load_personas()
    Enum.map(data["personas"], & &1["id"])
  end

  @doc """
  Gets caption templates for a persona, with placeholder substitution.

  Returns a list of ready-to-use captions with {adj} and {noun} placeholders
  replaced with random values from the seed data.
  """
  def get_caption_templates(persona_id) do
    data = load_personas()
    persona = Enum.find(data["personas"], fn p -> p["id"] == persona_id end)

    if persona do
      adjectives = data["adjectives"]
      nouns = data["nouns"]

      Enum.map(persona["caption_templates"] || [], fn template ->
        template
        |> String.replace("{adj}", Enum.random(adjectives))
        |> String.replace("{noun}", Enum.random(nouns))
      end)
    else
      []
    end
  end

  @doc """
  Gets workflow types for a persona.

  These represent the kinds of FloImg workflows this persona typically uses.
  """
  def get_workflow_types(persona_id) do
    case get_persona(persona_id) do
      nil -> []
      persona -> persona["workflow_types"] || []
    end
  end

  @doc """
  Gets a random prompt template for a persona.

  These are DALL-E prompts tailored to each persona's style and interests.
  Returns nil if persona not found or has no prompts.
  """
  def get_random_prompt(persona_id) do
    case get_persona(persona_id) do
      nil -> nil
      persona ->
        prompts = persona["prompt_templates"] || []
        if prompts == [], do: nil, else: Enum.random(prompts)
    end
  end

  @doc """
  Gets all prompt templates for a persona.
  """
  def get_prompt_templates(persona_id) do
    case get_persona(persona_id) do
      nil -> []
      persona -> persona["prompt_templates"] || []
    end
  end

  @doc """
  Generates bot attributes from a persona definition.

  The index parameter ensures deterministic name generation -
  the same persona + index will always produce the same bot name.

  ## Examples

      iex> persona = Seeds.get_persona("product_photographer")
      iex> Seeds.generate_bot_from_persona(persona, 1, %{adjectives: [...], nouns: [...]})
      %{
        name: "Bright Studio",
        username: "studio_bright_1",
        persona_id: "product_photographer",
        personality: "...",
        ...
      }
  """
  def generate_bot_from_persona(persona, index, data \\ nil) do
    data = data || load_personas()
    adjectives = data["adjectives"]
    nouns = data["nouns"]

    # Deterministic selection based on persona + index
    adj_index = :erlang.phash2({persona["id"], index, :adj}, length(adjectives))
    noun_index = :erlang.phash2({persona["id"], index, :noun}, length(nouns))
    template_index = :erlang.phash2({persona["id"], index, :template}, length(persona["name_templates"]))

    adj = Enum.at(adjectives, adj_index)
    noun = Enum.at(nouns, noun_index)
    template = Enum.at(persona["name_templates"], template_index)

    # Generate name from template
    name =
      template
      |> String.replace("{adj}", adj)
      |> String.replace("{noun}", noun)

    # Generate unique username
    username = "#{persona["username_prefix"]}#{String.downcase(adj)}_#{index}"

    probabilities = persona["probabilities"]

    %{
      name: name,
      username: username,
      persona_id: persona["id"],
      personality: persona["personality"],
      vibe: persona["vibe"],
      interests: persona["interests"],
      post_probability: probabilities["post"],
      comment_probability: probabilities["comment"],
      like_probability: probabilities["like"]
    }
  end

  @doc """
  Selects a persona using weighted random selection.

  Personas with higher weights are more likely to be selected.
  Uses the provided random value (0.0-1.0) for deterministic testing.
  """
  def weighted_random_persona(personas, random_value \\ nil) do
    random_value = random_value || :rand.uniform()

    total_weight = Enum.reduce(personas, 0, fn p, acc -> acc + (p["weight"] || 1.0) end)

    target = random_value * total_weight

    {selected, _} =
      Enum.reduce_while(personas, {nil, 0}, fn persona, {_selected, cumulative} ->
        new_cumulative = cumulative + (persona["weight"] || 1.0)

        if new_cumulative >= target do
          {:halt, {persona, new_cumulative}}
        else
          {:cont, {persona, new_cumulative}}
        end
      end)

    selected || List.last(personas)
  end

  @doc """
  Seeds bots into the database.

  This function can be called from a release:

      /app/bin/floimg_fleet eval 'FloimgFleet.Seeds.seed_bots(6)'

  ## Examples

      # Seed 6 bots
      Seeds.seed_bots(6)

      # Seed 3 product photographers
      Seeds.seed_bots(3, persona: "product_photographer")
  """
  def seed_bots(count \\ 6, opts \\ []) do
    alias FloimgFleet.Bots
    alias FloimgFleet.FloImgAPI.Users

    persona_filter = Keyword.get(opts, :persona)
    provision = Keyword.get(opts, :provision, true)

    IO.puts("\nSeeding #{count} bots...")

    if persona_filter do
      IO.puts("Using persona: #{persona_filter}")
    else
      IO.puts("Using weighted random persona distribution")
    end

    if provision do
      IO.puts("Will provision bots in FSC")
    else
      IO.puts("Skipping FSC provisioning (local only)")
    end

    IO.puts("")

    bots = generate_bot_batch(count: count, persona: persona_filter)

    results =
      Enum.map(bots, fn bot_attrs ->
        case Bots.create_bot(bot_attrs) do
          {:ok, bot} ->
            IO.puts("  ✓ Created: #{bot.name} (@#{bot.username}) [#{bot.persona_id}]")

            # Provision in FSC if enabled
            if provision do
              case Users.provision_bot_user(bot) do
                {:ok, _response} ->
                  IO.puts("    ↳ Provisioned in FSC")

                {:error, reason} ->
                  IO.puts("    ↳ FSC provisioning failed: #{inspect(reason)}")
              end
            end

            {:ok, bot}

          {:error, changeset} ->
            errors = format_changeset_errors(changeset)
            IO.puts("  ✗ Failed to create #{bot_attrs.name}: #{errors}")
            {:error, changeset}
        end
      end)

    successful = Enum.count(results, fn {status, _} -> status == :ok end)
    failed = Enum.count(results, fn {status, _} -> status == :error end)

    IO.puts("")
    IO.puts("Done! Created #{successful} bots, #{failed} failed.")

    {:ok, successful, failed}
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} -> "#{field}: #{Enum.join(errors, ", ")}" end)
    |> Enum.join("; ")
  end

  @doc """
  Generates a batch of bots with weighted persona distribution.

  ## Options

    * `:count` - Number of bots to generate (default: 6)
    * `:persona` - Specific persona ID to use for all bots (default: nil, uses weighted random)

  ## Examples

      # Generate 10 bots with weighted distribution
      Seeds.generate_bot_batch(count: 10)

      # Generate 3 product photographers
      Seeds.generate_bot_batch(count: 3, persona: "product_photographer")
  """
  def generate_bot_batch(opts \\ []) do
    count = Keyword.get(opts, :count, 6)
    persona_filter = Keyword.get(opts, :persona, nil)

    data = load_personas()
    personas = data["personas"]

    1..count
    |> Enum.map(fn index ->
      persona =
        if persona_filter do
          Enum.find(personas, fn p -> p["id"] == persona_filter end) ||
            raise "Unknown persona: #{persona_filter}"
        else
          # Use index as seed for deterministic but varied selection
          :rand.seed(:exsss, {index, 12345, 67890})
          weighted_random_persona(personas)
        end

      generate_bot_from_persona(persona, index, data)
    end)
  end
end
