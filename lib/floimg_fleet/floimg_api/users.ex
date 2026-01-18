defmodule FloimgFleet.FloImgAPI.Users do
  @moduledoc """
  User provisioning API for Fleet bots.

  Uses the standard admin users endpoint with service token authentication.
  The endpoint accepts either admin session OR service token with "users:write" permission.
  """

  alias FloimgFleet.FloImgAPI.Client
  alias FloimgFleet.Bots.Schemas.Bot

  require Logger

  @doc """
  Provisions a bot user in FSC.

  Creates a user account for the bot so it can post to the gallery.
  This is idempotent - calling it with the same bot will return the
  existing user if already provisioned.

  ## Parameters

    * `bot` - A Bot struct with id, name, username, and persona_id

  ## Returns

    * `{:ok, %{id: user_id, username: username, created: boolean}}`
    * `{:error, reason}`

  ## Example

      iex> Users.provision_bot_user(bot)
      {:ok, %{"id" => "bot_123", "username" => "studio_bright_1", "created" => true}}
  """
  def provision_bot_user(%Bot{} = bot) do
    body = %{
      botId: bot.id,
      name: bot.name,
      username: bot.username,
      isBot: true,
      botPersonaId: bot.persona_id
    }

    # Use nil for bot param since this is a service-level call
    case Client.post(nil, "/api/admin/users/invite", body) do
      {:ok, response} ->
        created = response["created"]
        Logger.info("Provisioned bot user: #{bot.username} (created: #{created})")
        {:ok, response}

      {:error, {:validation_error, details}} ->
        Logger.error("Failed to provision bot #{bot.username}: validation error - #{inspect(details)}")
        {:error, {:validation_error, details}}

      {:error, reason} ->
        Logger.error("Failed to provision bot #{bot.username}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Deletes a bot user from FSC.

  ## Parameters

    * `bot_id` - The bot ID (same as FSC user ID)

  ## Returns

    * `{:ok, %{deleted: true}}`
    * `{:error, reason}`
  """
  def delete_bot_user(bot_id) when is_binary(bot_id) do
    case Client.delete(nil, "/api/admin/users/#{bot_id}") do
      {:ok, response} ->
        Logger.info("Deleted bot user: #{bot_id}")
        {:ok, response}

      {:error, {:not_found, _}} ->
        # Already deleted, treat as success
        {:ok, %{"deleted" => true}}

      {:error, reason} ->
        Logger.error("Failed to delete bot user #{bot_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Provisions multiple bot users in FSC.

  Returns a summary of successes and failures.

  ## Example

      iex> Users.provision_bot_users(bots)
      {:ok, %{provisioned: 5, failed: 1, errors: [%{bot_id: "...", error: "..."}]}}
  """
  def provision_bot_users(bots) when is_list(bots) do
    results =
      bots
      |> Enum.map(fn bot ->
        case provision_bot_user(bot) do
          {:ok, _} -> {:ok, bot.id}
          {:error, reason} -> {:error, bot.id, reason}
        end
      end)

    provisioned = Enum.count(results, fn r -> match?({:ok, _}, r) end)
    failed = Enum.count(results, fn r -> match?({:error, _, _}, r) end)

    errors =
      results
      |> Enum.filter(fn r -> match?({:error, _, _}, r) end)
      |> Enum.map(fn {:error, bot_id, reason} -> %{bot_id: bot_id, error: inspect(reason)} end)

    {:ok, %{provisioned: provisioned, failed: failed, errors: errors}}
  end
end
