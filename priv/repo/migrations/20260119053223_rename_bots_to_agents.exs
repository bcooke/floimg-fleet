defmodule FloimgFleet.Repo.Migrations.RenameBotsToAgents do
  use Ecto.Migration

  def change do
    # Rename bots table to agents
    rename table(:agents), to: table(:agents)

    # Rename bot_activities table to agent_activities
    rename table(:agent_activities), to: table(:agent_activities)

    # Rename bot_id column to agent_id in agent_activities
    rename table(:agent_activities), :agent_id, to: :agent_id
  end
end
