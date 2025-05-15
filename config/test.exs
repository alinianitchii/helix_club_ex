import Config

config :people, People.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "people_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10


# Configure the logger
config :logger, level: :debug

# Configure the sandbox
config :people, :sql_sandbox, true
