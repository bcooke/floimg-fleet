defmodule FloimgFleet.Repo.Migrations.RenameBotsToAgents do
  use Ecto.Migration

  def change do
    # Rename bots table to agents
    rename table(:bots), to: table(:agents)

    # Rename bot_activities table to agent_activities
    rename table(:bot_activities), to: table(:agent_activities)

    # Rename bot_id column to agent_id in agent_activities
    rename table(:agent_activities), :bot_id, to: :agent_id
  end
end
