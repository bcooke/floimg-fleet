defmodule FloimgFleet.Repo.Migrations.AddPersonaIdToBots do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      add :persona_id, :string
    end

    create index(:agents, [:persona_id])
  end
end
