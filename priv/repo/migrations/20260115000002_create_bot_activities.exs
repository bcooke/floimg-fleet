defmodule FloimgFleet.Repo.Migrations.CreateBotActivities do
  use Ecto.Migration

  def change do
    create table(:bot_activities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bot_id, references(:bots, type: :binary_id, on_delete: :delete_all), null: false

      add :event_type, :string, null: false
      add :message, :string, null: false
      add :emoji, :string
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:bot_activities, [:bot_id])
    create index(:bot_activities, [:event_type])
    create index(:bot_activities, [:inserted_at])
  end
end
