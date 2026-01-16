defmodule FloimgFleet.Bots.Commands.PauseBot do
  @moduledoc """
  Command to pause a running bot.
  """

  alias FloimgFleet.Bots.Queries.GetBot
  alias FloimgFleet.Runtime.BotAgent

  defstruct [:bot_id]

  @type t :: %__MODULE__{bot_id: String.t()}

  @spec execute(t()) :: :ok | {:error, term()}
  def execute(%__MODULE__{bot_id: bot_id}) do
    case GetBot.execute(bot_id) do
      {:ok, bot} ->
        if bot.pid do
          pid = string_to_pid(bot.pid)
          BotAgent.pause(pid)
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
