defmodule FloimgFleet.Bots.Commands.DeleteBot do
  @moduledoc """
  Command to soft-delete a bot.
  """

  alias FloimgFleet.Repo
  alias FloimgFleet.Bots.Schemas.Bot
  alias FloimgFleet.Bots.Queries.GetBot
  alias FloimgFleet.Runtime.BotSupervisor

  defstruct [:bot_id]

  @type t :: %__MODULE__{bot_id: String.t()}

  @spec execute(t()) :: {:ok, Bot.t()} | {:error, term()}
  def execute(%__MODULE__{bot_id: bot_id}) do
    case GetBot.execute(bot_id) do
      {:ok, bot} ->
        # Stop the bot if running
        if bot.pid do
          BotSupervisor.stop_bot(bot.pid)
        end

        # Soft delete
        bot
        |> Bot.changeset(%{deleted_at: DateTime.utc_now(), status: :idle, pid: nil})
        |> Repo.update()

      {:error, _} = error ->
        error
    end
  end
end
