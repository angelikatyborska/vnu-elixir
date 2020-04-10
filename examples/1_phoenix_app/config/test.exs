use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_app, PhoenixAppWeb.Endpoint,
  http: [port: 4002],
  server: false

config :phoenix_app, :vnu_server_url, "http://localhost:8888"

# Print only warnings and errors during test
config :logger, level: :warn
