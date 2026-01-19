defmodule FloimgFleet.FloImgAPI.Interactions do
  @moduledoc """
  Interaction-related API endpoints for likes and comments.

  Note: These endpoints use the unified /api/showcase API which supports
  both session auth (human users) and service token + X-Agent-Id (agents).
  """

  alias FloimgFleet.FloImgAPI.Client

  @doc """
  Like a post.

  Returns `{:ok, %{"success" => true, "liked" => true, "likes_count" => N}}` on success.
  """
  def like_post(agent, post_id) do
    case Client.post(agent, "/api/showcase/#{post_id}/like", %{}) do
      {:ok, response} -> {:ok, normalize_like_response(response)}
      error -> error
    end
  end

  @doc """
  Unlike a post.

  The showcase API uses toggle behavior - calling like again unlikes.
  This function calls like which will unlike if already liked.

  Returns `{:ok, %{"liked" => false, "likes_count" => N}}` on success.
  """
  def unlike_post(agent, post_id) do
    # Showcase API doesn't have a separate unlike endpoint
    # The POST /showcase/:id/like toggles - it will unlike if already liked
    # So we just call like again
    like_post(agent, post_id)
  end

  @doc """
  Add a comment to a post.

  ## Example

      add_comment(agent, "post-123", "This is awesome!")
  """
  def add_comment(agent, post_id, content) do
    body = %{content: content}

    case Client.post(agent, "/api/showcase/#{post_id}/comments", body) do
      {:ok, response} -> {:ok, normalize_comment_response(response)}
      error -> error
    end
  end

  @doc """
  Get comments for a post.

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20, maps to limit)
  """
  def get_comments(agent, post_id, opts \\ []) do
    # Map Fleet's pagination to showcase API format
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    query_params = %{
      limit: per_page,
      offset: (page - 1) * per_page
    }

    query = URI.encode_query(query_params)
    path = "/api/showcase/#{post_id}/comments?#{query}"

    case Client.get(agent, path) do
      {:ok, %{"comments" => comments}} ->
        {:ok, %{
          "comments" => Enum.map(comments, &normalize_comment/1),
          "page" => page,
          "per_page" => per_page
        }}

      error ->
        error
    end
  end

  # Normalize showcase response to snake_case format expected by Fleet
  defp normalize_like_response(response) do
    %{
      "success" => response["success"] || true,
      "liked" => response["liked"],
      "likes_count" => response["likeCount"] || 0
    }
  end

  defp normalize_comment_response(%{"comment" => comment}) do
    %{
      "comment" => normalize_comment(comment)
    }
  end

  defp normalize_comment_response(response), do: response

  defp normalize_comment(comment) do
    %{
      "id" => comment["id"],
      "content" => comment["content"],
      "created_at" => comment["createdAt"],
      "author" => normalize_author(comment["user"])
    }
  end

  defp normalize_author(nil), do: nil

  defp normalize_author(user) do
    %{
      "id" => user["id"],
      "username" => user["username"],
      "name" => user["name"],
      "avatar_url" => user["avatarUrl"]
    }
  end
end
