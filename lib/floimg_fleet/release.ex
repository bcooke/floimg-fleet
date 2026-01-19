defmodule FloimgFleet.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix.
  """

  @app :floimg_fleet

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Seeds agents from persona definitions.

  Usage from release:
      /app/bin/floimg_fleet eval 'FloimgFleet.Release.seed()'
      /app/bin/floimg_fleet eval 'FloimgFleet.Release.seed(10)'
      /app/bin/floimg_fleet eval 'FloimgFleet.Release.seed(3, persona: "product_photographer")'
  """
  def seed(count \\ 6, opts \\ []) do
    load_app()
    start_app()
    FloimgFleet.Seeds.seed_agents(count, opts)
  end

  defp start_app do
    Application.ensure_all_started(@app)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
