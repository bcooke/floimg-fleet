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

  @doc """
  Build a workflow for social media content - generates at high res and resizes for Instagram.
  Demonstrates FloImg's resize capabilities.
  """
  def build_social_media_workflow(prompt, opts \\ []) do
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
        "out" => "original"
      },
      %{
        "kind" => "transform",
        "op" => "resize",
        "in" => "original",
        "params" => %{
          "width" => 1080,
          "height" => 1080,
          "fit" => "cover"
        },
        "out" => "instagram_square"
      },
      %{
        "kind" => "save",
        "in" => "instagram_square",
        "destination" => "cloud"
      }
    ]
  end

  @doc """
  Build a workflow for product photography - generates and applies color adjustments.
  Demonstrates FloImg's transform capabilities.
  """
  def build_product_workflow(prompt, opts \\ []) do
    model = Keyword.get(opts, :model, "dall-e-3")
    quality = Keyword.get(opts, :quality, "hd")

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
        "out" => "product_shot"
      },
      %{
        "kind" => "transform",
        "op" => "adjust",
        "in" => "product_shot",
        "params" => %{
          "brightness" => 1.05,
          "contrast" => 1.1,
          "saturation" => 1.1
        },
        "out" => "enhanced"
      },
      %{
        "kind" => "save",
        "in" => "enhanced",
        "destination" => "cloud"
      }
    ]
  end

  @doc """
  Build a workflow for pixel art - generates and applies pixel-perfect resize.
  Demonstrates FloImg's nearest-neighbor scaling.
  """
  def build_pixel_art_workflow(prompt, opts \\ []) do
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
        "out" => "pixel_art"
      },
      %{
        "kind" => "transform",
        "op" => "resize",
        "in" => "pixel_art",
        "params" => %{
          "width" => 512,
          "height" => 512,
          "fit" => "contain",
          "kernel" => "nearest"
        },
        "out" => "scaled"
      },
      %{
        "kind" => "save",
        "in" => "scaled",
        "destination" => "cloud"
      }
    ]
  end

  @doc """
  Build a workflow for AI art - generates at HD quality.
  Demonstrates FloImg's high-quality generation.
  """
  def build_ai_art_workflow(prompt, opts \\ []) do
    model = Keyword.get(opts, :model, "dall-e-3")

    [
      %{
        "kind" => "generate",
        "generator" => "openai",
        "params" => %{
          "prompt" => prompt,
          "model" => model,
          "size" => "1792x1024",
          "quality" => "hd"
        },
        "out" => "artwork"
      },
      %{
        "kind" => "save",
        "in" => "artwork",
        "destination" => "cloud"
      }
    ]
  end

  @doc """
  Get workflow builder for a specific persona.
  Returns {builder_function, opts} tuple.
  """
  def workflow_for_persona(persona_id) do
    case persona_id do
      "product_photographer" -> {:build_product_workflow, [quality: "hd"]}
      "social_marketer" -> {:build_social_media_workflow, []}
      "indie_game_dev" -> {:build_pixel_art_workflow, []}
      "ai_artist" -> {:build_ai_art_workflow, []}
      "data_viz" -> {:build_generation_workflow, []}
      "ux_designer" -> {:build_generation_workflow, []}
      _ -> {:build_generation_workflow, []}
    end
  end
end
