defmodule FloimgFleet.FloImgAPI do
  @moduledoc """
  HTTP client for interacting with the FloImg gallery API.

  This module provides the interface for bots to perform actions on FloImg:
  - Create and view gallery posts
  - Like and comment on content
  - Browse and discover content

  ## Configuration

      config :floimg_fleet, FloimgFleet.FloImgAPI,
        base_url: "https://api.floimg.com",
        bot_secret: System.get_env("FLOIMG_BOT_SECRET")

  ## Usage

      # Create a post
      FloImgAPI.create_post(bot, %{image_url: "...", caption: "..."})

      # Like a post
      FloImgAPI.like_post(bot, post_id)

      # Get feed
      FloImgAPI.get_feed(bot)
  """

  alias FloimgFleet.FloImgAPI.{Gallery, Interactions}

  @doc """
  Create a new gallery post.
  """
  defdelegate create_post(bot, attrs), to: Gallery

  @doc """
  Get a single post by ID.
  """
  defdelegate get_post(bot, post_id), to: Gallery

  @doc """
  List gallery posts with optional filters.
  """
  defdelegate list_posts(bot, opts \\ []), to: Gallery

  @doc """
  Get personalized feed for a bot.
  """
  defdelegate get_feed(bot, opts \\ []), to: Gallery

  @doc """
  Get trending/popular posts.
  """
  defdelegate get_trending(bot, opts \\ []), to: Gallery

  @doc """
  Like a post.
  """
  defdelegate like_post(bot, post_id), to: Interactions

  @doc """
  Unlike a post.
  """
  defdelegate unlike_post(bot, post_id), to: Interactions

  @doc """
  Add a comment to a post.
  """
  defdelegate add_comment(bot, post_id, content), to: Interactions

  @doc """
  Get comments for a post.
  """
  defdelegate get_comments(bot, post_id, opts \\ []), to: Interactions
end
