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
  def get(agent, path, opts \\ []) do
    request(agent, :get, path, opts)
  end

  @doc """
  Make a POST request to the FloImg API.
  """
  def post(agent, path, body, opts \\ []) do
    request(agent, :post, path, Keyword.put(opts, :json, body))
  end

  @doc """
  Make a DELETE request to the FloImg API.
  """
  def delete(agent, path, opts \\ []) do
    request(agent, :delete, path, opts)
  end

  defp request(agent, method, path, opts) do
    url = build_url(path)
    headers = build_headers(agent)

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

    log_request(method, path, agent, duration, result)

    result
  end

  defp build_url(path) do
    base_url = config(:base_url, "https://api.floimg.com")
    "#{base_url}#{path}"
  end

  defp build_headers(agent) do
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

    # Add agent ID header so the API can look up the agent's FSC user
    # Uses username instead of ID because FSC users are provisioned with email: {username}@agent.floimg.local
    if agent do
      [{"x-agent-id", agent.username} | headers]
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
    # Handle Fleet budget error codes
    case body["code"] do
      "FLEET_DAILY_BUDGET_EXCEEDED" ->
        {:error, {:fleet_daily_budget, body["resetAt"]}}

      "FLEET_MONTHLY_BUDGET_EXCEEDED" ->
        {:error, {:fleet_monthly_budget, body["resetAt"]}}

      "AGENT_DAILY_LIMIT_EXCEEDED" ->
        {:error, {:agent_daily_limit, body}}

      "AGENT_MONTHLY_LIMIT_EXCEEDED" ->
        {:error, {:agent_monthly_limit, body}}

      _ ->
        {:error, {:rate_limited, body["error"] || "Rate limited"}}
    end
  end

  defp handle_response({:ok, %Req.Response{status: 503, body: body}}) do
    # Handle Fleet paused (killswitch)
    case body["code"] do
      "FLEET_PAUSED" ->
        {:error, {:fleet_paused, body["error"]}}

      _ ->
        {:error, {:service_unavailable, body["error"] || "Service unavailable"}}
    end
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

  defp log_request(method, path, agent, duration, result) do
    status =
      case result do
        {:ok, _} -> "ok"
        {:error, {code, _}} -> "error:#{code}"
        {:error, {code, _, _}} -> "error:#{code}"
      end

    agent_name = if agent, do: agent.name, else: "anonymous"

    Logger.debug(
      "FloImgAPI #{String.upcase(to_string(method))} #{path} " <>
        "[agent=#{agent_name}] [#{duration}ms] [#{status}]"
    )
  end

  defp config(key, default \\ nil) do
    Application.get_env(:floimg_fleet, FloimgFleet.FloImgAPI, [])
    |> Keyword.get(key, default)
  end
end
