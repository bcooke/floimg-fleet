defmodule FloimgFleet.Bots.Commands.ResumeAll do
  @moduledoc """
  Command to resume all paused bots.
  """

  alias FloimgFleet.Runtime.BotSupervisor
  alias FloimgFleet.Runtime.BotAgent

  defstruct []

  @type t :: %__MODULE__{}

  @spec execute(t()) :: :ok
  def execute(%__MODULE__{}) do
    for pid <- BotSupervisor.list_children() do
      BotAgent.resume(pid)
    end

    :ok
  end
end
