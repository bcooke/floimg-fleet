defmodule FloimgFleet.Agents do
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
      {:ok, bot} = Agents.create_agent(%{name: "PhotoBot", personality: "enthusiastic"})

      # Start a bot
      {:ok, pid} = Agents.start_agent(bot.id)

      # Pause all bots
      :ok = Agents.pause_all()

  """

  alias FloimgFleet.Agents.Queries
  alias FloimgFleet.Agents.Commands

  # ============================================================================
  # Queries
  # ============================================================================

  @doc """
  Lists all bots with optional filtering and pagination.
  """
  defdelegate list_agents(params \\ %{}), to: Queries.ListAgents, as: :execute

  @doc """
  Gets a single bot by ID.
  """
  defdelegate get_agent(id), to: Queries.GetAgent, as: :execute

  @doc """
  Gets a bot by ID, raising if not found.
  """
  defdelegate get_agent!(id), to: Queries.GetAgent, as: :execute!

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
  def create_agent(attrs) do
    attrs = atomize_keys(attrs)
    Commands.CreateAgent.execute(struct(Commands.CreateAgent, attrs))
  end

  @doc """
  Updates an existing bot.
  """
  def update_agent(agent_id, attrs) do
    attrs = atomize_keys(attrs)
    attrs = Map.put(attrs, :agent_id, agent_id)
    Commands.UpdateAgent.execute(struct(Commands.UpdateAgent, attrs))
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
  def start_agent(agent_id) do
    Commands.StartAgent.execute(%Commands.StartAgent{agent_id: agent_id})
  end

  @doc """
  Pauses a running bot.
  """
  def pause_agent(agent_id) do
    Commands.PauseAgent.execute(%Commands.PauseAgent{agent_id: agent_id})
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
  def delete_agent(agent_id) do
    Commands.DeleteAgent.execute(%Commands.DeleteAgent{agent_id: agent_id})
  end
end
