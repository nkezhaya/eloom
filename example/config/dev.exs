import Config

# Configure your database
config :example, Example.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "example_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :example, Example.EventRepo, url: "http://default:@localhost:8123/example_dev"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :example, ExampleWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "e5WKhiFyv/RUhMdrNs9bt3OGP/yMGkb0xovjAsZ1NgdjxW8iHZ6ynQXUHiCsv8ff",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:eloom, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:eloom, ~w(--watch)]},
    esbuild: {Esbuild, :install_and_run, [:example, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:example, ~w(--watch)]}
  ],
  reloadable_apps: [:example, :eloom],
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/example_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :example, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

config :phoenix_live_reload, :dirs, ["", "../"]
