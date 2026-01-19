defmodule FloimgFleet.Repo.Migrations.CreateBots do
  use Ecto.Migration

  def change do
    create table(:bots, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :username, :string, null: false
      add :status, :string, default: "idle"

      # Personality
      add :personality, :text
      add :vibe, :string
      add :interests, {:array, :string}, default: []

      # Behavior configuration
      add :post_probability, :float, default: 0.3
      add :comment_probability, :float, default: 0.4
      add :like_probability, :float, default: 0.5
      add :min_action_interval_seconds, :integer, default: 60
      add :max_action_interval_seconds, :integer, default: 300

      # Runtime tracking
      add :pid, :string
      add :last_action_at, :utc_datetime
      add :total_posts, :integer, default: 0
      add :total_comments, :integer, default: 0
      add :total_likes, :integer, default: 0

      # Soft delete
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:bots, [:username])
    create index(:bots, [:status])
    create index(:bots, [:deleted_at])
  end
end
