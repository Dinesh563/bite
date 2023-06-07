# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bite,
  ecto_repos: [Bite.Repo]

# Configures the endpoint
config :bite, BiteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QduoS3h5DKjDmRUTQD9aof01mGed0E2T7jR9RZbwhGDikz9+gPI134tgQzo+2sJu",
  render_errors: [view: BiteWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bite.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "2i1iKJah"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
