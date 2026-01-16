defmodule FloimgFleet.Runtime.BotSupervisor do
  @moduledoc """
  DynamicSupervisor for bot agents.

  Allows starting and stopping bot agents at runtime. Each bot
  is a GenServer that manages its own lifecycle and actions.

  ## Examples

      # Start a bot
      {:ok, pid} = BotSupervisor.start_bot(bot)

      # Stop a bot
      :ok = BotSupervisor.stop_bot(pid)

      # Count running bots
      BotSupervisor.count_children()

  """

  use DynamicSupervisor

  alias FloimgFleet.Runtime.BotAgent

  @me __MODULE__

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a bot agent for the given bot configuration.
  """
  def start_bot(bot) do
    DynamicSupervisor.start_child(@me, {BotAgent, bot})
  end

  @doc """
  Stops a bot agent by PID or PID string (stored in database).
  """
  def stop_bot(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(@me, pid)
  end

  def stop_bot(pid_string) when is_binary(pid_string) do
    pid = string_to_pid(pid_string)
    stop_bot(pid)
  end

  @doc """
  Stops all running bot agents.
  """
  def stop_all do
    for {_, pid, _, _} <- DynamicSupervisor.which_children(@me) do
      DynamicSupervisor.terminate_child(@me, pid)
    end

    :ok
  end

  @doc """
  Returns the count of running bot agents.
  """
  def count_children do
    DynamicSupervisor.count_children(@me).active
  end

  @doc """
  Lists all running bot PIDs.
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
