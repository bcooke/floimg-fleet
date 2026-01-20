defmodule FloimgFleet.FloImgAPI.Workflows do
  @moduledoc """
  Workflow execution via FloImg Studio Cloud API.

  Executes FloImg pipelines and returns generated image URLs for gallery posting.
  """

  alias FloimgFleet.FloImgAPI.Client

  @doc """
  Execute a workflow pipeline and return the generated image URLs.

  ## Parameters

  - `agent` - The agent executing the workflow (for auth headers)
  - `steps` - List of pipeline steps in FloImg format
  - `name` - Optional name for the workflow (for logging)

  ## Returns

  - `{:ok, %{"imageUrls" => [...], "status" => "completed"}}` on success
  - `{:error, reason}` on failure

  ## Example

      steps = [
        %{
          "kind" => "generate",
          "generator" => "openai",
          "params" => %{
            "prompt" => "A sunset over mountains",
            "model" => "dall-e-3",
            "size" => "1024x1024"
          },
          "out" => "image"
        },
        %{
          "kind" => "save",
          "in" => "image",
          "destination" => "cloud"
        }
      ]

      execute_workflow(agent, steps, "fleet-gallery-generation")
  """
  def execute_workflow(agent, steps, name \\ nil) do
    body = %{
      steps: steps,
      name: name || "fleet-agent-workflow"
    }

    Client.post(agent, "/api/execute/sync", body)
  end

  @doc """
  Build a simple AI image generation workflow.

  Creates a workflow that generates an image with DALL-E and saves to cloud storage.

  ## Parameters

  - `prompt` - The image generation prompt
  - `opts` - Options:
    - `:model` - Model to use (default: "dall-e-3")
    - `:size` - Image size (default: "1024x1024")
    - `:quality` - Image quality, "standard" or "hd" (default: "standard")

  ## Returns

  A list of pipeline steps ready for `execute_workflow/3`.
  """
  def build_generation_workflow(prompt, opts \\ []) do
    model = Keyword.get(opts, :model, "dall-e-3")
    size = Keyword.get(opts, :size, "1024x1024")
    quality = Keyword.get(opts, :quality, "standard")

    [
      %{
        "kind" => "generate",
        "generator" => "openai",
        "params" => %{
          "prompt" => prompt,
          "model" => model,
          "size" => size,
          "quality" => quality
        },
        "out" => "generated_image"
      },
      %{
        "kind" => "save",
        "in" => "generated_image",
        "destination" => "cloud"
      }
    ]
  end

  @doc """
  Build a workflow that generates and resizes an image.

  Useful for social media content that needs specific dimensions.
  """
  def build_generation_with_resize_workflow(prompt, width, height, opts \\ []) do
    model = Keyword.get(opts, :model, "dall-e-3")
    quality = Keyword.get(opts, :quality, "standard")

    [
      %{
        "kind" => "generate",
        "generator" => "openai",
        "params" => %{
          "prompt" => prompt,
          "model" => model,
          "size" => "1024x1024",
          "quality" => quality
        },
        "out" => "generated_image"
      },
      %{
        "kind" => "transform",
        "op" => "resize",
        "in" => "generated_image",
        "params" => %{
          "width" => width,
          "height" => height,
          "fit" => "cover"
        },
        "out" => "resized_image"
      },
      %{
        "kind" => "save",
        "in" => "resized_image",
        "destination" => "cloud"
      }
    ]
  end
end
