defmodule FloimgFleet.Repo.Migrations.AddPersonaIdToBots do
  use Ecto.Migration

  def change do
    alter table(:bots) do
      add :persona_id, :string
    end

    create index(:bots, [:persona_id])
  end
end
