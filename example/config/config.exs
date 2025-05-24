# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :example,
  ecto_repos: [Example.Repo, Example.EventRepo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :example, ExampleWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ExampleWeb.ErrorHTML, json: ExampleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Example.PubSub,
  live_view: [signing_salt: "/rjt10PI"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.18.6",
  eloom: [
    args: ~w(js/app.js --bundle --minify --target=es2020 --outdir=../dist/js),
    cd: Path.expand("../../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  example: [
    args: ~w(js/app.js --bundle --target=es2020 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.5",
  eloom: [
    args: ~w(
      --input=assets/css/app.css
      --output=dist/css/app.css
    ),
    cd: Path.expand("../..", __DIR__)
  ],
  example: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :eloom,
  repo: Example.Repo,
  event_repo: Example.EventRepo,
  geoip: [
    account_id: "account id",
    license_key: "license key",
    edition: "edition"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

if File.exists?(Path.expand("config.secret.exs", __DIR__)) do
  import_config "config.secret.exs"
end
