defmodule Train2cal do
  @moduledoc """
  Train2cal keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @base_url "https://www.oui.sncf/vsa/api/v2/orders/fr_FR"
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"

  @countries %{
    # TODO translate / add more
    "FR" => "France",
    "IT" => "Italie"
  }

  @classes %{
    # TODO translate
    "2" => "2nde classe",
    "1" => "1ère classe"
  }

  def clean_field(value) do
    value
    |> String.trim
    |> String.upcase
    |> URI.encode
  end

  def call_api(reference, name) do
    reference = clean_field reference
    name = clean_field name
    # url = "https://httpbin.org/headers"
    url = "#{@base_url}/#{name}/#{reference}?source=vsa&withAftersaleEligibility=true"
    # The API returns a 403 with HTML if the user-agent doesn’t look like a browser and there's no 'Accept' header
    headers = ["User-Agent": @user_agent, "Accept": "*/*"]
    HTTPoison.get(url, headers)
  end

  def check_trip(reference, name) do
    case call_api(reference, name) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode!(body) do
          %{"status" => status, "order" => trip_payload} ->
            case status do
              "SUCCESS" ->
                {:ok, format_trip(trip_payload)}
              "NO_MATCHING_DATA" ->
                {:not_found, nil}
              _ -> # e.g. "TECHNICAL_ERROR"
                {:api_error, nil}
            end
          _ ->
            {:api_error, nil}
        end
      _ ->
        {:api_error, nil}
    end
  end

  def get_trip_details(trip) do
    train_folder = trip["trainFolders"]
                   |> hd

    reference = train_folder["reference"]
    name = train_folder["ownerName"]

    passengers = train_folder["passengers"]
    segments = train_folder["travels"]
               |> Enum.flat_map(fn travel -> travel["segments"] end)

    %{
      reference: reference,
      name: name,
      passengers: passengers,
      segments: segments
    }
  end

  def format_trip(trip) do
    details = get_trip_details(trip)

    %{
      ok: true,
      reference: details.reference,
      name: details.name,
      icalhref: "data:text/plain;charset=utf-8," <> trip_ical(details)
      # maybe add more info here to display the trip details in HTML
    }
  end

  def trip_ical(trip_details) do
    passengers_map = make_passengers_map(trip_details.passengers)

    events = trip_details.segments
             |> Enum.map(
                  fn segment ->
                    segment_event(segment, passengers_map)
                  end
                )

    %ICalendar{events: events}
    |> ICalendar.to_ics
  end

  def segment_event(segment, passengers_map) do
    dt_start = iso2dt(segment["departureDate"])
    dt_end = iso2dt(segment["arrivalDate"])

    origin = segment["origin"]
    origin_city = origin["cityName"]
    destination_city = segment["destination"]["cityName"]
    title = "#{origin_city} → #{destination_city}"

    transport_name = get_transport_name(segment["transport"])
    class_name = @classes[segment["comfortClass"]]

    placements_description = get_placements_description(segment["placements"], passengers_map)
    fares_description = get_fares_description(segment["fares"], passengers_map)

    description = [
                    transport_name,
                    class_name,
                    "",
                    placements_description,
                    "\n\n--------------",
                    fares_description
                  ]
                  |> Enum.join("\n")

    %ICalendar.Event{
      summary: title,
      dtstart: dt_start,
      dtend: dt_end,
      location: location_address(origin),
      description: description
    }
  end

  def iso2dt(date_string) do
    date = date_string <> "Z"
           |> DateTime.from_iso8601()
           |> elem(1)
    # to set the timezone:
    #  |> DateTime.to_naive
    #  |> DateTime.from_naive!("Europe/Paris", Tzdata.TimeZoneDatabase)

    {
      {date.year, date.month, date.day},
      {date.hour, date.minute, date.second}
    }
  end

  def location_address(%{"stationName" => station, "countryCode" => countryCode}) do
    country = @countries[countryCode]

    station_city = case Regex.run(~r/(.+) \((.+)\)$/, station) do
      nil -> station <> "\n"
      [_, station, city] -> "#{station}\n#{city}, "
    end

    station_city <> country
  end

  def get_transport_name(%{"label" => label, "number" => number}) do
    label <> " " <> number
  end

  def get_placements_description(placements, passengers_map) do
    placements
    |> Enum.map(
         fn {passenger_id, placement} ->
           passenger_name = passengers_map[passenger_id].name
           passenger_name <> " : " <> placement_string(placement)
         end
       )
    |> Enum.join("\n")
  end

  def placement_string(placement) do
    coach = String.trim placement["coachNumber"], "0"
    seat = String.trim placement["seatNumber"], "0"
    position = String.downcase placement["position"]["label"]

    # TODO translate
    "voiture #{coach}, place #{seat} (#{position})"
  end

  def get_fares_description(fares, passengers_map) do
    fares
    |> Enum.map(
         fn {passenger_id, fare} ->
           passenger = passengers_map[passenger_id]

           [
             passenger.name,
             passenger.cards,
             fare["name"],
             case fare["conditions"] do
               nil -> nil
               conditions -> HtmlEntities.decode(conditions)
             end
           ]
           |> Enum.reject(fn x -> is_nil(x) end)
           |> Enum.join("\n")
         end
       )
    |> Enum.join("\n\n")
  end

  def make_passengers_map(passengers) do
    passengers
    |> Enum.reduce(
         %{},
         fn passenger, acc ->
           Map.put(
             acc,
             passenger["passengerId"],
             %{
               name: passenger["displayName"],
               cards: ["commercialCard", "fidelityCard"]
                      |> Enum.map(fn key -> passenger[key] end)
                      |> Enum.reject(fn x -> is_nil(x) end)
                      |> Enum.map(fn card -> card["label"] end)
                      |> Enum.join(" ; ")
             }
           )
         end
       )
  end
end
