defmodule FloimgFleet.FloImgAPI do
  @moduledoc """
  HTTP client for interacting with the FloImg gallery API.

  This module provides the interface for agents to perform actions on FloImg:
  - Create and view gallery posts
  - Like and comment on content
  - Browse and discover content

  ## Configuration

      config :floimg_fleet, FloimgFleet.FloImgAPI,
        base_url: "https://api.floimg.com",
        service_token: System.get_env("FLOIMG_SERVICE_TOKEN")

  ## Usage

      # Create a post
      FloImgAPI.create_post(agent, %{image_url: "...", caption: "..."})

      # Like a post
      FloImgAPI.like_post(agent, post_id)

      # Get feed
      FloImgAPI.get_feed(agent)
  """

  alias FloimgFleet.FloImgAPI.{Gallery, Interactions, Workflows}

  @doc """
  Create a new gallery post.
  """
  defdelegate create_post(agent, attrs), to: Gallery

  @doc """
  Get a single post by ID.
  """
  defdelegate get_post(agent, post_id), to: Gallery

  @doc """
  List gallery posts with optional filters.
  """
  defdelegate list_posts(agent, opts \\ []), to: Gallery

  @doc """
  Get personalized feed for an agent.
  """
  defdelegate get_feed(agent, opts \\ []), to: Gallery

  @doc """
  Get trending/popular posts.
  """
  defdelegate get_trending(agent, opts \\ []), to: Gallery

  @doc """
  Like a post.
  """
  defdelegate like_post(agent, post_id), to: Interactions

  @doc """
  Unlike a post.
  """
  defdelegate unlike_post(agent, post_id), to: Interactions

  @doc """
  Add a comment to a post.
  """
  defdelegate add_comment(agent, post_id, content), to: Interactions

  @doc """
  Get comments for a post.
  """
  defdelegate get_comments(agent, post_id, opts \\ []), to: Interactions

  # ============================================================================
  # Workflow Execution
  # ============================================================================

  @doc """
  Execute a workflow pipeline and return generated image URLs.
  """
  defdelegate execute_workflow(agent, steps, name \\ nil), to: Workflows

  @doc """
  Build a simple AI image generation workflow.
  """
  defdelegate build_generation_workflow(prompt, opts \\ []), to: Workflows

  @doc """
  Build a workflow that generates and resizes an image.
  """
  defdelegate build_generation_with_resize_workflow(prompt, width, height, opts \\ []),
    to: Workflows
end
