defmodule FloimgFleet.Bots.Commands.StartBot do
  @moduledoc """
  Command to start a bot agent.
  """

  alias FloimgFleet.Bots.Queries.GetBot
  alias FloimgFleet.Runtime.BotSupervisor

  defstruct [:bot_id]

  @type t :: %__MODULE__{bot_id: String.t()}

  @spec execute(t()) :: {:ok, pid()} | {:error, term()}
  def execute(%__MODULE__{bot_id: bot_id}) do
    case GetBot.execute(bot_id) do
      {:ok, bot} ->
        BotSupervisor.start_bot(bot)

      {:error, _} = error ->
        error
    end
  end
end
