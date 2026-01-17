defmodule FloimgFleet.FloImgAPI.Client do
  @moduledoc """
  Base HTTP client for FloImg API requests.

  Handles authentication, request building, and response parsing.
  """

  require Logger

  @default_timeout 30_000

  @doc """
  Make a GET request to the FloImg API.
  """
  def get(bot, path, opts \\ []) do
    request(bot, :get, path, opts)
  end

  @doc """
  Make a POST request to the FloImg API.
  """
  def post(bot, path, body, opts \\ []) do
    request(bot, :post, path, Keyword.put(opts, :json, body))
  end

  @doc """
  Make a DELETE request to the FloImg API.
  """
  def delete(bot, path, opts \\ []) do
    request(bot, :delete, path, opts)
  end

  defp request(bot, method, path, opts) do
    url = build_url(path)
    headers = build_headers(bot)

    start_time = System.monotonic_time(:millisecond)

    result =
      Req.new(
        method: method,
        url: url,
        headers: headers,
        receive_timeout: @default_timeout
      )
      |> Req.merge(opts)
      |> Req.request()
      |> handle_response()

    duration = System.monotonic_time(:millisecond) - start_time

    log_request(method, path, bot, duration, result)

    result
  end

  defp build_url(path) do
    base_url = config(:base_url, "https://api.floimg.com")
    "#{base_url}#{path}"
  end

  defp build_headers(bot) do
    service_token = config(:service_token)

    headers = [
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"user-agent", "FloImgFleet/1.0"}
    ]

    # Add service token authentication (full token, e.g., fst_floimg-fleet_...)
    headers =
      if service_token do
        [{"authorization", "Bearer #{service_token}"} | headers]
      else
        headers
      end

    # Add bot ID header so the API knows which bot is making the request
    if bot do
      [{"x-bot-id", bot.id} | headers]
    else
      headers
    end
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}})
       when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %Req.Response{status: 401, body: body}}) do
    {:error, {:unauthorized, body["error"] || "Unauthorized"}}
  end

  defp handle_response({:ok, %Req.Response{status: 403, body: body}}) do
    {:error, {:forbidden, body["error"] || "Forbidden"}}
  end

  defp handle_response({:ok, %Req.Response{status: 404, body: body}}) do
    {:error, {:not_found, body["error"] || "Not found"}}
  end

  defp handle_response({:ok, %Req.Response{status: 422, body: body}}) do
    {:error, {:validation_error, body["errors"] || body["error"] || "Validation failed"}}
  end

  defp handle_response({:ok, %Req.Response{status: 429, body: body}}) do
    {:error, {:rate_limited, body["error"] || "Rate limited"}}
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}})
       when status >= 500 do
    {:error, {:server_error, body["error"] || "Server error"}}
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}}) do
    {:error, {:unexpected_status, status, body}}
  end

  defp handle_response({:error, %Req.TransportError{reason: reason}}) do
    {:error, {:transport_error, reason}}
  end

  defp handle_response({:error, reason}) do
    {:error, {:request_failed, reason}}
  end

  defp log_request(method, path, bot, duration, result) do
    status =
      case result do
        {:ok, _} -> "ok"
        {:error, {code, _}} -> "error:#{code}"
        {:error, {code, _, _}} -> "error:#{code}"
      end

    bot_name = if bot, do: bot.name, else: "anonymous"

    Logger.debug(
      "FloImgAPI #{String.upcase(to_string(method))} #{path} " <>
        "[bot=#{bot_name}] [#{duration}ms] [#{status}]"
    )
  end

  defp config(key, default \\ nil) do
    Application.get_env(:floimg_fleet, FloimgFleet.FloImgAPI, [])
    |> Keyword.get(key, default)
  end
end
