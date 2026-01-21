defmodule FloimgFleet.LLM.Client do
  @moduledoc """
  LLM client for generating agent content.

  Supports both Ollama (local development) and OpenAI (production).
  Uses the configured provider based on environment variables.

  ## Configuration

  Set via environment variables:
  - `LLM_PROVIDER`: "ollama" or "openai" (default: "ollama")
  - `OLLAMA_URL`: Ollama server URL (default: "http://localhost:11434")
  - `OLLAMA_MODEL`: Model to use (default: "llama3.2")
  - `OPENAI_API_KEY`: OpenAI API key (required for openai provider)
  - `OPENAI_MODEL`: OpenAI model (default: "gpt-4o-mini")
  """

  alias FloimgFleet.Seeds

  require Logger

  @ollama_default_url "http://localhost:11434"
  @ollama_default_model "llama3.2"
  @openai_default_model "gpt-4o-mini"

  @doc """
  Generate a caption for an agent post based on the agent's personality.
  """
  def generate_caption(agent) do
    prompt = build_caption_prompt(agent)
    generate(prompt)
  end

  @doc """
  Generate a DALL-E prompt for image generation based on the agent's persona.

  Returns {:ok, prompt} or {:error, reason}.
  """
  def generate_prompt(agent) do
    prompt = build_image_prompt(agent)
    generate(prompt)
  end

  @doc """
  Generate a comment for a post based on the agent's personality and the post content.
  """
  def generate_comment(agent, post) do
    prompt = build_comment_prompt(agent, post)
    generate(prompt)
  end

  @doc """
  Decide what action an agent should take next based on its personality and current context.

  Returns one of: :post, :comment, :like, :browse
  """
  def decide_action(agent, context \\ %{}) do
    prompt = build_decision_prompt(agent, context)

    case generate(prompt) do
      {:ok, response} ->
        action = parse_action(response)
        {:ok, action}

      {:error, reason} ->
        Logger.warning("LLM decision failed: #{inspect(reason)}, falling back to random")
        {:ok, fallback_action(agent)}
    end
  end

  # ============================================================================
  # Core Generation
  # ============================================================================

  defp generate(prompt) do
    provider = get_provider()

    case provider do
      "openai" -> generate_openai(prompt)
      _ -> generate_ollama(prompt)
    end
  end

  defp generate_ollama(prompt) do
    url = get_ollama_url()
    model = get_ollama_model()

    body = %{
      model: model,
      prompt: prompt,
      stream: false,
      options: %{
        temperature: 0.8,
        num_predict: 150
      }
    }

    case Req.post("#{url}/api/generate", json: body, receive_timeout: 30_000) do
      {:ok, %{status: 200, body: %{"response" => response}}} ->
        {:ok, String.trim(response)}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Ollama error: status=#{status}, body=#{inspect(body)}")
        {:error, "Ollama returned status #{status}"}

      {:error, reason} ->
        Logger.error("Ollama request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp generate_openai(prompt) do
    api_key = get_openai_api_key()

    if is_nil(api_key) do
      Logger.error("OPENAI_API_KEY not set")
      {:error, "OpenAI API key not configured"}
    else
      model = get_openai_model()

      body = %{
        model: model,
        messages: [
          %{
            role: "system",
            content:
              "You are a creative social media user. Keep responses short (1-2 sentences max). Be authentic and natural."
          },
          %{role: "user", content: prompt}
        ],
        max_tokens: 100,
        temperature: 0.8
      }

      headers = [
        {"authorization", "Bearer #{api_key}"},
        {"content-type", "application/json"}
      ]

      case Req.post("https://api.openai.com/v1/chat/completions",
             json: body,
             headers: headers,
             receive_timeout: 30_000
           ) do
        {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => content}} | _]}}} ->
          {:ok, String.trim(content)}

        {:ok, %{status: status, body: body}} ->
          Logger.error("OpenAI error: status=#{status}, body=#{inspect(body)}")
          {:error, "OpenAI returned status #{status}"}

        {:error, reason} ->
          Logger.error("OpenAI request failed: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  # ============================================================================
  # Prompt Building
  # ============================================================================

  defp build_image_prompt(agent) do
    name = sanitize(agent.name) || "User"
    personality = sanitize(agent.personality) || "a creative person"
    vibe = sanitize(agent.vibe) || "casual"
    interests = format_interests(agent.interests)
    workflows = format_workflows(agent.persona_id)

    # Get example prompts from persona to guide the style
    example_prompts = Seeds.get_prompt_templates(agent.persona_id)

    examples_text =
      if Enum.empty?(example_prompts) do
        ""
      else
        examples = example_prompts |> Enum.shuffle() |> Enum.take(4) |> Enum.join("\n- ")
        "Here are examples of prompts in your style:\n- #{examples}"
      end

    """
    You are #{name}, #{personality}.
    Your vibe is: #{vibe}
    #{interests}
    #{workflows}

    #{examples_text}

    Generate a DALL-E prompt for a VISUALLY STUNNING image you would create.
    The image should be gallery-worthy and impressive - something that makes people stop scrolling.
    The prompt should be detailed (40-80 words) and match your personality and interests.
    Include style, lighting, composition, mood, and quality descriptors like "masterpiece", "stunning", "award-winning", "hyperdetailed".
    Output ONLY the prompt text, nothing else.
    """
  end

  defp build_caption_prompt(agent) do
    name = sanitize(agent.name) || "User"
    personality = sanitize(agent.personality) || "a friendly social media user"
    vibe = sanitize(agent.vibe) || "casual"
    interests = format_interests(agent.interests)
    workflows = format_workflows(agent.persona_id)

    """
    You are #{name}, #{personality}.
    Your vibe is: #{vibe}
    #{interests}
    #{workflows}

    You just created an image using FloImg (an image workflow platform).
    Write a short caption for your post (1-2 sentences max).
    Be natural and authentic to your personality.
    Reference what you actually did with the image if relevant.
    Don't use hashtags.
    Just output the caption text, nothing else.
    """
  end

  defp build_comment_prompt(agent, post) do
    name = sanitize(agent.name) || "User"
    personality = sanitize(agent.personality) || "a friendly social media user"
    vibe = sanitize(agent.vibe) || "casual"
    interests = format_interests(agent.interests)
    post_caption = sanitize(post["caption"]) || "an image"

    post_author =
      case post["user"] do
        %{"displayName" => name} when is_binary(name) and name != "" -> sanitize(name)
        %{"username" => username} when is_binary(username) -> sanitize(username)
        _ -> "someone"
      end

    # Add variety to comment style
    comment_style =
      Enum.random([
        "give a genuine compliment",
        "ask a curious question about their technique",
        "share a brief related thought",
        "express appreciation"
      ])

    """
    You are #{name}, #{personality}.
    Your vibe is: #{vibe}
    #{interests}

    You're looking at a post by #{post_author} with this caption: "#{post_caption}"

    Write a short, genuine comment (1 sentence max).
    Style: #{comment_style}
    Be natural and authentic to your personality. Don't use hashtags.
    If you share their interest area, you can reference that connection.
    Just output the comment text, nothing else.
    """
  end

  defp build_decision_prompt(agent, context) do
    name = sanitize(agent.name) || "User"
    personality = sanitize(agent.personality) || "a friendly social media user"
    vibe = sanitize(agent.vibe) || "casual"
    interests = format_interests(agent.interests)
    feed_count = Map.get(context, :feed_count, "some")
    recent_action = sanitize(Map.get(context, :recent_action, "browsing"))

    """
    You are #{name}, #{personality}.
    Your vibe is: #{vibe}
    #{interests}

    You're on a social platform for sharing AI-generated images.
    There are #{feed_count} posts in the feed.
    Your last action was: #{recent_action}

    What would you like to do next? Choose ONE:
    - POST: Share a new image
    - COMMENT: Comment on someone's post
    - LIKE: Like a post you enjoyed
    - BROWSE: Just scroll and look around

    Respond with just the action word (POST, COMMENT, LIKE, or BROWSE).
    """
  end

  defp format_interests(nil), do: ""
  defp format_interests([]), do: ""

  defp format_interests(interests) when is_list(interests) do
    sanitized =
      interests
      |> Enum.map(&sanitize/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.take(10)

    if Enum.empty?(sanitized) do
      ""
    else
      "Your interests include: #{Enum.join(sanitized, ", ")}"
    end
  end

  defp format_workflows(nil), do: ""

  defp format_workflows(persona_id) do
    workflow_types = Seeds.get_workflow_types(persona_id)

    if Enum.empty?(workflow_types) do
      ""
    else
      formatted =
        workflow_types
        |> Enum.map(&format_workflow_type/1)
        |> Enum.join(", ")

      "You typically use FloImg for: #{formatted}"
    end
  end

  defp format_workflow_type(type) do
    type
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  # ============================================================================
  # Input Sanitization (Prompt Injection Prevention)
  # ============================================================================

  @max_input_length 500

  defp sanitize(nil), do: nil

  defp sanitize(input) when is_binary(input) do
    input
    |> String.replace(~r/\n\n+/, " ")
    |> String.replace(~r/[^\w\s.,!?'"-]/, "")
    |> String.slice(0, @max_input_length)
    |> String.trim()
    |> case do
      "" -> nil
      sanitized -> sanitized
    end
  end

  defp sanitize(_), do: nil

  # ============================================================================
  # Response Parsing
  # ============================================================================

  defp parse_action(response) do
    response
    |> String.upcase()
    |> String.trim()
    |> case do
      "POST" ->
        :post

      "COMMENT" ->
        :comment

      "LIKE" ->
        :like

      "BROWSE" ->
        :browse

      other ->
        # Try to extract action from a longer response
        cond do
          String.contains?(other, "POST") -> :post
          String.contains?(other, "COMMENT") -> :comment
          String.contains?(other, "LIKE") -> :like
          true -> :browse
        end
    end
  end

  defp fallback_action(agent) do
    # Weighted random fallback based on agent's configured probabilities
    rand = :rand.uniform()

    cond do
      rand < agent.post_probability -> :post
      rand < agent.post_probability + agent.comment_probability -> :comment
      rand < agent.post_probability + agent.comment_probability + agent.like_probability -> :like
      true -> :browse
    end
  end

  # ============================================================================
  # Configuration
  # ============================================================================

  defp get_provider do
    System.get_env("LLM_PROVIDER", "ollama")
  end

  defp get_ollama_url do
    System.get_env("OLLAMA_URL", @ollama_default_url)
  end

  defp get_ollama_model do
    System.get_env("OLLAMA_MODEL", @ollama_default_model)
  end

  defp get_openai_api_key do
    System.get_env("OPENAI_API_KEY")
  end

  defp get_openai_model do
    System.get_env("OPENAI_MODEL", @openai_default_model)
  end
end
