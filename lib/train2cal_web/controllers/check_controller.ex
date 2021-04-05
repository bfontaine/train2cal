defmodule Train2calWeb.CheckController do
  use Train2calWeb, :controller

  action_fallback(Train2calWeb.FallbackController)

  def index(conn, %{"ref" => reference, "name" => name}) do
    case Train2cal.check_trip(reference, name) do
      {:ok, trip} ->
        render(conn, "trip.json", trip: trip)
      {:not_found, _} ->
        {:error, :not_found}
      _ ->
        {:error, :other}
    end
  end
end