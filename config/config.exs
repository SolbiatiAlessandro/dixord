# This file is responsible for configuring your application
# j and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dixord,
  ecto_repos: [Dixord.Repo]

# Configures the endpoint
config :dixord, DixordWeb.Endpoint,
  http: [ip: {192, 168, 0, 11}],
  secret_key_base: "HtTG2+UPHVzR9sfnFvYstr1Upb+2RjghLk5pNBcTH+24uFHMPxUkjdwKzzd9+TNG",
  render_errors: [view: DixordWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dixord.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Dd+wSzCozE4bmbmYJ2IzTTwFQGq3lISA"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

config :dixord, :pow,
  user: Dixord.Accounts.User,
  repo: Dixord.Repo,
  web_module: DixordWeb

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
