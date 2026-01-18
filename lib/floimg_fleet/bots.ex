defmodule FloimgFleet.Bots do
  @moduledoc """
  The Bots context.

  This is the core gateway module for all bot-related functionality.
  Follows the CQRS pattern with separate commands and queries.

  ## Architecture

  - Commands: Write operations (create, update, delete, start, pause)
  - Queries: Read operations (list, get, activity)
  - Schemas: Ecto schemas for persistence
  - Runtime: GenServer processes for active bots

  ## Examples

      # Create a bot
      {:ok, bot} = Bots.create_bot(%{name: "PhotoBot", personality: "enthusiastic"})

      # Start a bot
      {:ok, pid} = Bots.start_bot(bot.id)

      # Pause all bots
      :ok = Bots.pause_all()

  """

  alias FloimgFleet.Bots.Queries
  alias FloimgFleet.Bots.Commands

  # ============================================================================
  # Queries
  # ============================================================================

  @doc """
  Lists all bots with optional filtering and pagination.
  """
  defdelegate list_bots(params \\ %{}), to: Queries.ListBots, as: :execute

  @doc """
  Gets a single bot by ID.
  """
  defdelegate get_bot(id), to: Queries.GetBot, as: :execute

  @doc """
  Gets a bot by ID, raising if not found.
  """
  defdelegate get_bot!(id), to: Queries.GetBot, as: :execute!

  @doc """
  Gets recent activity for a bot or all bots.
  """
  defdelegate get_activity(params \\ %{}), to: Queries.GetActivity, as: :execute

  # ============================================================================
  # Commands
  # ============================================================================

  @doc """
  Creates a new bot with the given attributes.
  """
  def create_bot(attrs) do
    attrs = atomize_keys(attrs)
    Commands.CreateBot.execute(struct(Commands.CreateBot, attrs))
  end

  @doc """
  Updates an existing bot.
  """
  def update_bot(bot_id, attrs) do
    attrs = atomize_keys(attrs)
    attrs = Map.put(attrs, :bot_id, bot_id)
    Commands.UpdateBot.execute(struct(Commands.UpdateBot, attrs))
  end

  # Converts string keys to atoms for struct creation
  defp atomize_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      key = if is_binary(key), do: String.to_existing_atom(key), else: key
      {key, val}
    end
  end

  @doc """
  Starts a bot, creating a GenServer process for it.
  """
  def start_bot(bot_id) do
    Commands.StartBot.execute(%Commands.StartBot{bot_id: bot_id})
  end

  @doc """
  Pauses a running bot.
  """
  def pause_bot(bot_id) do
    Commands.PauseBot.execute(%Commands.PauseBot{bot_id: bot_id})
  end

  @doc """
  Pauses all running bots.
  """
  def pause_all do
    Commands.PauseAll.execute(%Commands.PauseAll{})
  end

  @doc """
  Resumes all paused bots.
  """
  def resume_all do
    Commands.ResumeAll.execute(%Commands.ResumeAll{})
  end

  @doc """
  Deletes a bot (soft delete).
  """
  def delete_bot(bot_id) do
    Commands.DeleteBot.execute(%Commands.DeleteBot{bot_id: bot_id})
  end
end
