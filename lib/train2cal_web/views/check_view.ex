defmodule Train2calWeb.CheckView do
  use Train2calWeb, :view

  # https://elixirforum.com/t/handle-401-error-for-json-api/29502/2
  def render("trip.json", %{trip: trip}) do
    trip
  end
end
