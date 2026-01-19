defmodule Mix.Tasks.Fleet.Swarm do
  @shortdoc "Manage the agent swarm"
  @moduledoc """
  Start, stop, and check the status of the agent swarm.

  ## Commands

      # Start all agents
      mix fleet.swarm start

      # Stop all agents
      mix fleet.swarm stop

      # Show swarm status
      mix fleet.swarm status

      # Start agents of a specific persona
      mix fleet.swarm start --persona product_photographer

  """

  use Mix.Task

  alias FloimgFleet.Agents

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
    Mix.shell().error("  start          Start all agents")
    Mix.shell().error("  start --persona <id>  Start agents of a specific persona")
    Mix.shell().error("  stop           Stop all running agents")
    Mix.shell().error("  status         Show swarm status")
  end

  defp start_all do
    agents = Agents.list_agents()
    startable = Enum.filter(agents, &can_start?/1)

    if Enum.empty?(startable) do
      Mix.shell().info("No agents to start (all are already running)")
    else
      Mix.shell().info("Starting #{length(startable)} agents...")

      Enum.each(startable, fn agent ->
        case Agents.start_agent(agent.id) do
          {:ok, _} ->
            Mix.shell().info("  ✓ Started: #{agent.name}")

          {:error, reason} ->
            Mix.shell().error("  ✗ Failed to start #{agent.name}: #{inspect(reason)}")
        end
      end)
    end
  end

  defp start_by_persona(persona_id) do
    agents = Agents.list_agents()
    persona_agents = Enum.filter(agents, fn agent -> agent.persona_id == persona_id end)
    startable = Enum.filter(persona_agents, &can_start?/1)

    if Enum.empty?(persona_agents) do
      Mix.shell().error("No agents found with persona: #{persona_id}")
    else
      if Enum.empty?(startable) do
        Mix.shell().info("All #{persona_id} agents are already running")
      else
        Mix.shell().info("Starting #{length(startable)} #{persona_id} agents...")

        Enum.each(startable, fn agent ->
          case Agents.start_agent(agent.id) do
            {:ok, _} ->
              Mix.shell().info("  ✓ Started: #{agent.name}")

            {:error, reason} ->
              Mix.shell().error("  ✗ Failed to start #{agent.name}: #{inspect(reason)}")
          end
        end)
      end
    end
  end

  defp stop_all do
    case Agents.pause_all() do
      {:ok, count} ->
        Mix.shell().info("Stopped #{count} agents")

      {:error, reason} ->
        Mix.shell().error("Failed to stop agents: #{inspect(reason)}")
    end
  end

  defp show_status do
    agents = Agents.list_agents()

    by_status =
      Enum.group_by(agents, & &1.status)
      |> Enum.map(fn {status, agents} -> {status, length(agents)} end)
      |> Map.new()

    by_persona =
      Enum.group_by(agents, & &1.persona_id)
      |> Enum.map(fn {persona, agents} -> {persona || "custom", length(agents)} end)
      |> Map.new()

    running = Map.get(by_status, :running, 0)
    paused = Map.get(by_status, :paused, 0)
    idle = Map.get(by_status, :idle, 0)
    error = Map.get(by_status, :error, 0)

    Mix.shell().info("")
    Mix.shell().info("Agent Swarm Status")
    Mix.shell().info("==================")
    Mix.shell().info("")
    Mix.shell().info("Total: #{length(agents)} agents")
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

  defp can_start?(agent), do: agent.status in [:idle, :paused]

  defp format_persona(nil), do: "custom"
  defp format_persona(id), do: String.replace(id, "_", " ")
end
