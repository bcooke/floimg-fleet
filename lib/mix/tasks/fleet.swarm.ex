defmodule Mix.Tasks.Fleet.Swarm do
  @shortdoc "Manage the bot swarm"
  @moduledoc """
  Start, stop, and check the status of the bot swarm.

  ## Commands

      # Start all bots
      mix fleet.swarm start

      # Stop all bots
      mix fleet.swarm stop

      # Show swarm status
      mix fleet.swarm status

      # Start bots of a specific persona
      mix fleet.swarm start --persona product_photographer

  """

  use Mix.Task

  alias FloimgFleet.Bots

  @requirements ["app.start"]

  @impl Mix.Task
  def run(["start" | args]) do
    {opts, _, _} = OptionParser.parse(args, strict: [persona: :string])
    persona = Keyword.get(opts, :persona)

    if persona do
      start_by_persona(persona)
    else
      start_all()
    end
  end

  def run(["stop" | _args]) do
    stop_all()
  end

  def run(["status" | _args]) do
    show_status()
  end

  def run(_) do
    Mix.shell().error("Usage: mix fleet.swarm <start|stop|status> [options]")
    Mix.shell().error("")
    Mix.shell().error("Commands:")
    Mix.shell().error("  start          Start all bots")
    Mix.shell().error("  start --persona <id>  Start bots of a specific persona")
    Mix.shell().error("  stop           Stop all running bots")
    Mix.shell().error("  status         Show swarm status")
  end

  defp start_all do
    bots = Bots.list_bots()
    startable = Enum.filter(bots, &can_start?/1)

    if Enum.empty?(startable) do
      Mix.shell().info("No bots to start (all are already running)")
    else
      Mix.shell().info("Starting #{length(startable)} bots...")

      Enum.each(startable, fn bot ->
        case Bots.start_bot(bot.id) do
          {:ok, _} ->
            Mix.shell().info("  ✓ Started: #{bot.name}")

          {:error, reason} ->
            Mix.shell().error("  ✗ Failed to start #{bot.name}: #{inspect(reason)}")
        end
      end)
    end
  end

  defp start_by_persona(persona_id) do
    bots = Bots.list_bots()
    persona_bots = Enum.filter(bots, fn bot -> bot.persona_id == persona_id end)
    startable = Enum.filter(persona_bots, &can_start?/1)

    if Enum.empty?(persona_bots) do
      Mix.shell().error("No bots found with persona: #{persona_id}")
    else
      if Enum.empty?(startable) do
        Mix.shell().info("All #{persona_id} bots are already running")
      else
        Mix.shell().info("Starting #{length(startable)} #{persona_id} bots...")

        Enum.each(startable, fn bot ->
          case Bots.start_bot(bot.id) do
            {:ok, _} ->
              Mix.shell().info("  ✓ Started: #{bot.name}")

            {:error, reason} ->
              Mix.shell().error("  ✗ Failed to start #{bot.name}: #{inspect(reason)}")
          end
        end)
      end
    end
  end

  defp stop_all do
    case Bots.pause_all() do
      {:ok, count} ->
        Mix.shell().info("Stopped #{count} bots")

      {:error, reason} ->
        Mix.shell().error("Failed to stop bots: #{inspect(reason)}")
    end
  end

  defp show_status do
    bots = Bots.list_bots()

    by_status =
      Enum.group_by(bots, & &1.status)
      |> Enum.map(fn {status, bots} -> {status, length(bots)} end)
      |> Map.new()

    by_persona =
      Enum.group_by(bots, & &1.persona_id)
      |> Enum.map(fn {persona, bots} -> {persona || "custom", length(bots)} end)
      |> Map.new()

    running = Map.get(by_status, :running, 0)
    paused = Map.get(by_status, :paused, 0)
    idle = Map.get(by_status, :idle, 0)
    error = Map.get(by_status, :error, 0)

    Mix.shell().info("")
    Mix.shell().info("Bot Swarm Status")
    Mix.shell().info("================")
    Mix.shell().info("")
    Mix.shell().info("Total: #{length(bots)} bots")
    Mix.shell().info("")
    Mix.shell().info("By Status:")
    Mix.shell().info("  Running: #{running}")
    Mix.shell().info("  Paused:  #{paused}")
    Mix.shell().info("  Idle:    #{idle}")
    Mix.shell().info("  Error:   #{error}")
    Mix.shell().info("")
    Mix.shell().info("By Persona:")

    Enum.each(Enum.sort(by_persona), fn {persona, count} ->
      Mix.shell().info("  #{format_persona(persona)}: #{count}")
    end)

    Mix.shell().info("")
  end

  defp can_start?(bot), do: bot.status in [:idle, :paused]

  defp format_persona(nil), do: "custom"
  defp format_persona(id), do: String.replace(id, "_", " ")
end
