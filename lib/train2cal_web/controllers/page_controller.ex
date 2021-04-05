defmodule Train2calWeb.PageController do
  use Train2calWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
