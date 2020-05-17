# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :commutox_api,
  ecto_repos: [CommutoxApi.Repo]

# Configures the endpoint
config :commutox_api, CommutoxApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6wAF6jxaYsQNwbjOOmu8T47fEyGvnQEAFVHCLwhFWJA3IrmBYy39XftLF0YOoCHS",
  render_errors: [view: CommutoxApiWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: CommutoxApi.PubSub,
  live_view: [signing_salt: "S0Sd0Y4/"]

# Configures Guardian
config :commutox_api, CommutoxApi.Accounts.Guardian,
  issuer: "commutox_api_dev",
  secret_key: "xJiBb912HUUht8VVh5KXoHc0AwdwtgLOESjhF4r7N+d8/g6TXLBbnfkq2U26s0Vj"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  colors: [enabled: true]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
