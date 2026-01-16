defmodule FloimgFleet.FloImgAPI.Gallery do
  @moduledoc """
  Gallery-related API endpoints for creating and browsing posts.
  """

  alias FloimgFleet.FloImgAPI.Client

  @doc """
  Create a new gallery post.

  ## Attributes

  - `:image_url` - URL of the image to post (required)
  - `:caption` - Text caption for the post
  - `:workflow_id` - Optional ID of the workflow that generated the image

  ## Example

      create_post(bot, %{
        image_url: "https://cdn.floimg.com/images/123.png",
        caption: "Check out this cool generation!"
      })
  """
  def create_post(bot, attrs) do
    body = %{
      image_url: attrs[:image_url] || attrs["image_url"],
      caption: attrs[:caption] || attrs["caption"],
      workflow_id: attrs[:workflow_id] || attrs["workflow_id"]
    }

    Client.post(bot, "/api/gallery/posts", body)
  end

  @doc """
  Get a single post by ID.
  """
  def get_post(bot, post_id) do
    Client.get(bot, "/api/gallery/posts/#{post_id}")
  end

  @doc """
  List gallery posts with optional filters.

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20)
  - `:sort` - Sort order: "recent" or "popular" (default: "recent")
  - `:author_id` - Filter by author

  ## Example

      list_posts(bot, page: 2, sort: "popular")
  """
  def list_posts(bot, opts \\ []) do
    query =
      opts
      |> Keyword.take([:page, :per_page, :sort, :author_id])
      |> Enum.into(%{})
      |> URI.encode_query()

    path =
      if query == "" do
        "/api/gallery/posts"
      else
        "/api/gallery/posts?#{query}"
      end

    Client.get(bot, path)
  end

  @doc """
  Get personalized feed for a bot.

  The feed is tailored based on the bot's interests and past interactions.

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20)
  """
  def get_feed(bot, opts \\ []) do
    query =
      opts
      |> Keyword.take([:page, :per_page])
      |> Enum.into(%{})
      |> URI.encode_query()

    path =
      if query == "" do
        "/api/gallery/feed"
      else
        "/api/gallery/feed?#{query}"
      end

    Client.get(bot, path)
  end

  @doc """
  Get trending/popular posts.

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20)
  - `:timeframe` - Time window: "day", "week", "month" (default: "week")
  """
  def get_trending(bot, opts \\ []) do
    query =
      opts
      |> Keyword.take([:page, :per_page, :timeframe])
      |> Enum.into(%{})
      |> URI.encode_query()

    path =
      if query == "" do
        "/api/gallery/trending"
      else
        "/api/gallery/trending?#{query}"
      end

    Client.get(bot, path)
  end
end
