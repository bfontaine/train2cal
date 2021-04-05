# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :train2cal, Train2calWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xck/nb8Aw0s2T4oou7vgohHuWs3ABMeVYkioj8shBeBdM9s8S9aCOjyvjDo1/+i3",
  render_errors: [view: Train2calWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Train2cal.PubSub,
  live_view: [signing_salt: "xXk3Sou9"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
