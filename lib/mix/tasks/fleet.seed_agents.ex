defmodule Mix.Tasks.Fleet.SeedAgents do
  @shortdoc "Seeds bots from personas.json"

  @moduledoc """
  Seeds bots into the database using persona definitions.

  ## Usage

      # Seed 6 bots with weighted persona distribution (default)
      mix fleet.seed_agents

      # Seed a specific number of bots
      mix fleet.seed_agents --count 10

      # Seed bots of a specific persona only
      mix fleet.seed_agents --persona product_photographer --count 3

      # List available personas
      mix fleet.seed_agents --list

  ## Options

    * `--count`, `-n` - Number of bots to create (default: 6)
    * `--persona`, `-p` - Create only from specific persona
    * `--list`, `-l` - List available persona IDs

  ## Examples

      # Create one bot per persona
      mix fleet.seed_agents --count 6

      # Create a swarm of social marketers
      mix fleet.seed_agents --persona social_marketer --count 5

  """

  use Mix.Task

  alias FloimgFleet.Agents
  alias FloimgFleet.Seeds

  @switches [
    count: :integer,
    persona: :string,
    list: :boolean
  ]

  @aliases [
    n: :count,
    p: :persona,
    l: :list
  ]

  @impl Mix.Task
  def run(args) do
    {opts, _args, _} = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    # Start the application (including Repo)
    Mix.Task.run("app.start")

    cond do
      opts[:list] ->
        list_personas()

      true ->
        seed_agents(opts)
    end
  end

  defp list_personas do
    data = Seeds.load_personas()

    Mix.shell().info("\nAvailable personas:\n")

    for persona <- data["personas"] do
      Mix.shell().info("  #{persona["id"]}")
      Mix.shell().info("    Vibe: #{persona["vibe"]}")
      Mix.shell().info("    Interests: #{Enum.join(persona["interests"], ", ")}")
      Mix.shell().info("    Weight: #{persona["weight"]}")
      Mix.shell().info("")
    end
  end

  defp seed_agents(opts) do
    count = Keyword.get(opts, :count, 6)
    persona_filter = Keyword.get(opts, :persona)

    Mix.shell().info("\nSeeding #{count} bots...")

    if persona_filter do
      Mix.shell().info("Using persona: #{persona_filter}")
    else
      Mix.shell().info("Using weighted random persona distribution")
    end

    Mix.shell().info("")

    bots = Seeds.generate_bot_batch(count: count, persona: persona_filter)

    results =
      Enum.map(bots, fn bot_attrs ->
        case Agents.create_agent(bot_attrs) do
          {:ok, bot} ->
            Mix.shell().info("  ✓ Created: #{bot.name} (@#{bot.username}) [#{bot.persona_id}]")
            {:ok, bot}

          {:error, changeset} ->
            errors = format_errors(changeset)
            Mix.shell().error("  ✗ Failed to create #{bot_attrs.name}: #{errors}")
            {:error, changeset}
        end
      end)

    successful = Enum.count(results, fn {status, _} -> status == :ok end)
    failed = Enum.count(results, fn {status, _} -> status == :error end)

    Mix.shell().info("")
    Mix.shell().info("Done! Created #{successful} bots, #{failed} failed.")
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} -> "#{field}: #{Enum.join(errors, ", ")}" end)
    |> Enum.join("; ")
  end
end
