# Train2cal

**Train2cal** is a website to get iCalendar files from SNCF train reservations.

This used to be a feature provided by [Capitaine Train][ct]. Unfortunately Trainline killed it and recently re-released
it in a very basic way. Oui.SNCF has a more detailed iCalendar export feature, but not as good as Capitaine Train’s.

Note I learned Elixir and Vue while coding this.

[ct]: https://en.wikipedia.org/wiki/Trainline_EU

## Development

To start the Phoenix server:

* Install dependencies with `mix deps.get`
* Install Node.js dependencies with `npm install` inside the `assets` directory
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deploy

* [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Privacy Warning

While Train2cal doesn’t store any of your information, be aware that with your trip reference and name, one can get
access to all information regarding your trip, including:

- the expiry date of the bank card you paid with
- the last four digits of the bank card
- your postal address, email and phone number
- the name, birthdate, email and civility of all passengers as well as their commercial card numbers (e.g. "Avantage
  Week-end", etc)