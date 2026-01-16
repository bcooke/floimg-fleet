defmodule FloimgFleet.Repo do
  use Ecto.Repo,
    otp_app: :floimg_fleet,
    adapter: Ecto.Adapters.Postgres
end
