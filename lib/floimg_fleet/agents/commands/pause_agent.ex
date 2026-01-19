defmodule FloimgFleet.Agents.Commands.PauseAgent do
  @moduledoc """
  Command to pause a running bot.
  """

  alias FloimgFleet.Agents.Queries.GetAgent
  alias FloimgFleet.Runtime.AgentWorker

  defstruct [:agent_id]

  @type t :: %__MODULE__{agent_id: String.t()}

  @spec execute(t()) :: :ok | {:error, term()}
  def execute(%__MODULE__{agent_id: agent_id}) do
    case GetAgent.execute(agent_id) do
      {:ok, bot} ->
        if bot.pid do
          pid = string_to_pid(bot.pid)
          AgentWorker.pause(pid)
          :ok
        else
          {:error, :bot_not_running}
        end

      {:error, _} = error ->
        error
    end
  end

  defp string_to_pid(pid_string) do
    pid_string
    |> String.replace("#PID", "")
    |> String.to_charlist()
    |> :erlang.list_to_pid()
  end
end
