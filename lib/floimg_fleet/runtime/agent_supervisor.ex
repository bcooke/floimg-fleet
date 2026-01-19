defmodule FloimgFleet.Runtime.AgentSupervisor do
  @moduledoc """
  DynamicSupervisor for Fleet agents.

  Allows starting and stopping agents at runtime. Each agent
  is a GenServer that manages its own lifecycle and actions.

  ## Examples

      # Start an agent
      {:ok, pid} = AgentSupervisor.start_agent(agent)

      # Stop an agent
      :ok = AgentSupervisor.stop_agent(pid)

      # Count running agents
      AgentSupervisor.count_children()

  """

  use DynamicSupervisor

  alias FloimgFleet.Runtime.AgentWorker

  @me __MODULE__

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts an agent for the given agent configuration.
  """
  def start_agent(agent) do
    DynamicSupervisor.start_child(@me, {AgentWorker, agent})
  end

  @doc """
  Stops an agent by PID or PID string (stored in database).
  """
  def stop_agent(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(@me, pid)
  end

  def stop_agent(pid_string) when is_binary(pid_string) do
    pid = string_to_pid(pid_string)
    stop_agent(pid)
  end

  @doc """
  Stops all running agents.
  """
  def stop_all do
    for {_, pid, _, _} <- DynamicSupervisor.which_children(@me) do
      DynamicSupervisor.terminate_child(@me, pid)
    end

    :ok
  end

  @doc """
  Returns the count of running agents.
  """
  def count_children do
    DynamicSupervisor.count_children(@me).active
  end

  @doc """
  Lists all running agent PIDs.
  """
  def list_children do
    for {_, pid, _, _} <- DynamicSupervisor.which_children(@me), do: pid
  end

  # Convert PID string like "#PID<0.123.0>" to actual PID
  defp string_to_pid(pid_string) do
    pid_string
    |> String.replace("#PID", "")
    |> String.to_charlist()
    |> :erlang.list_to_pid()
  end
end
