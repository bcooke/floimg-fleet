defmodule FloimgFleet.FloImgAPI.Interactions do
  @moduledoc """
  Interaction-related API endpoints for likes and comments.
  """

  alias FloimgFleet.FloImgAPI.Client

  @doc """
  Like a post.

  Returns `{:ok, %{liked: true, likes_count: N}}` on success.
  """
  def like_post(bot, post_id) do
    Client.post(bot, "/api/gallery/posts/#{post_id}/like", %{})
  end

  @doc """
  Unlike a post.

  Returns `{:ok, %{liked: false, likes_count: N}}` on success.
  """
  def unlike_post(bot, post_id) do
    Client.delete(bot, "/api/gallery/posts/#{post_id}/like")
  end

  @doc """
  Add a comment to a post.

  ## Example

      add_comment(bot, "post-123", "This is awesome!")
  """
  def add_comment(bot, post_id, content) do
    body = %{content: content}
    Client.post(bot, "/api/gallery/posts/#{post_id}/comments", body)
  end

  @doc """
  Get comments for a post.

  ## Options

  - `:page` - Page number (default: 1)
  - `:per_page` - Items per page (default: 20)
  """
  def get_comments(bot, post_id, opts \\ []) do
    query =
      opts
      |> Keyword.take([:page, :per_page])
      |> Enum.into(%{})
      |> URI.encode_query()

    path =
      if query == "" do
        "/api/gallery/posts/#{post_id}/comments"
      else
        "/api/gallery/posts/#{post_id}/comments?#{query}"
      end

    Client.get(bot, path)
  end
end
