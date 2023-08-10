import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_app, PhoenixAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gp1+2v6i/38qbGXTebQprcSwKkTlUVZxJQEfYsbWB/PQ/1mSuWzN+tDuPsbS1lt8",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_app, :vnu_server_url, "http://localhost:8888"
