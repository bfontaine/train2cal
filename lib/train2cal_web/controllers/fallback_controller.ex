defmodule Train2calWeb.FallbackController do
  use Train2calWeb, :controller


  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(Train2calWeb.ErrorView)
    |> render("not_found.json")
  end

  def call(conn, {:error, :other}) do
    conn
    |> put_status(400)
    |> put_view(Train2calWeb.ErrorView)
    |> render("other.json")
  end
end