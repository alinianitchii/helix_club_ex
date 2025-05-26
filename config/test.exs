import Config

config :people, People.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "people_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  ownership_timeout: 10_000


# Configure the logger
config :logger, level: :debug

# Configure the sandbox
config :people, :sql_sandbox, true

config :people, http_port: 4000
