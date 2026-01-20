defmodule FloimgFleet.FloImgAPI.Gallery do
  @moduledoc """
  Showcase/gallery-related API endpoints for creating and browsing posts.

  Note: These endpoints use the unified /api/showcase API which supports
  both session auth (human users) and service token + X-Agent-Id (agents).
  """

  alias FloimgFleet.FloImgAPI.Client

  @doc """
  Create a new showcase post.

  ## Attributes

  - `:image_url` - URL of the image to post (required)
  - `:caption` - Text caption for the post (used as title + description)
  - `:workflow_id` - Optional ID of the workflow that generated the image

  ## Example

      create_post(agent, %{
        image_url: "https://cdn.floimg.com/images/123.png",
        caption: "Check out this cool generation!"
      })
  """
  def create_post(agent, attrs) do
    caption = attrs[:caption] || attrs["caption"] || "Agent Post"

    # Map to showcase API format (camelCase)
    # Filter out nil values to avoid Zod validation errors
    # (Zod's .optional() allows omitted fields but not explicit null)
    body =
      %{
        imageUrl: attrs[:image_url] || attrs["image_url"],
        title: String.slice(caption, 0, 200),
        description: caption,
        workflowId: attrs[:workflow_id] || attrs["workflow_id"]
      }
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    case Client.post(agent, "/api/showcase", body) do
      {:ok, response} -> {:ok, normalize_post_response(response)}
      error -> error
    end
  end

  @doc """
  Get a single post by ID.
  """
  def get_post(agent, post_id) do
    case Client.get(agent, "/api/showcase/#{post_id}") do
      {:ok, %{"item" => item}} -> {:ok, %{"post" => normalize_item(item)}}
      {:ok, response} -> {:ok, normalize_post_response(response)}
      error -> error
    end
  end

  @doc """
  List showcase posts with optional filters.

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20, maps to limit)
  - `:sort` - Sort order: "recent" or "popular" (default: "recent")
  - `:author_id` - Filter by author (not currently supported)

  ## Example

      list_posts(agent, page: 2, sort: "popular")
  """
  def list_posts(agent, opts \\ []) do
    # Map Fleet's pagination to showcase API format
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    sort = Keyword.get(opts, :sort, "recent")

    query_params = %{
      limit: per_page,
      offset: (page - 1) * per_page,
      sort: sort
    }

    query = URI.encode_query(query_params)
    path = "/api/showcase?#{query}"

    case Client.get(agent, path) do
      {:ok, %{"items" => items}} ->
        {:ok,
         %{
           "items" => Enum.map(items, &normalize_item/1),
           "page" => page,
           "per_page" => per_page
         }}

      error ->
        error
    end
  end

  @doc """
  Get feed for an agent (recent posts).

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20)
  """
  def get_feed(agent, opts \\ []) do
    # Feed is just recent posts in showcase
    list_posts(agent, opts)
  end

  @doc """
  Get trending/popular posts.

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20)
  - `:timeframe` - Not used (showcase doesn't filter by timeframe yet)
  """
  def get_trending(agent, opts \\ []) do
    opts_with_sort = Keyword.put(opts, :sort, "trending")
    list_posts(agent, opts_with_sort)
  end

  # Normalize showcase response to snake_case format expected by Fleet
  defp normalize_post_response(%{"showcaseItem" => item}) do
    %{
      "success" => true,
      "post" => normalize_item(item)
    }
  end

  defp normalize_post_response(response), do: response

  defp normalize_item(item) do
    %{
      "id" => item["id"],
      "caption" => item["description"] || item["title"],
      "category" => item["category"],
      "likes_count" => item["likeCount"] || 0,
      "comments_count" => item["commentCount"] || 0,
      "views_count" => item["viewCount"] || 0,
      "created_at" => item["createdAt"],
      "author" => normalize_author(item["user"]),
      "image" => item["image"]
    }
  end

  defp normalize_author(nil), do: nil

  defp normalize_author(user) do
    %{
      "id" => user["id"],
      "username" => user["username"],
      "name" => user["name"]
    }
  end
end
