defmodule FloimgFleet.Bots.Commands.PauseAll do
  @moduledoc """
  Command to pause all running bots.
  """

  alias FloimgFleet.Runtime.BotSupervisor
  alias FloimgFleet.Runtime.BotAgent

  defstruct []

  @type t :: %__MODULE__{}

  @spec execute(t()) :: :ok
  def execute(%__MODULE__{}) do
    for pid <- BotSupervisor.list_children() do
      BotAgent.pause(pid)
    end

    :ok
  end
end
