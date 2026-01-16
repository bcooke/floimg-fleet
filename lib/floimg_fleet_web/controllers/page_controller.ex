defmodule FloimgFleetWeb.PageController do
  use FloimgFleetWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
