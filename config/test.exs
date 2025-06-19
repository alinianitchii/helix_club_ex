import Config

config :logger, level: :debug

config :people, People.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "people_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 20

# Configure the sandbox
config :people, :sql_sandbox, true

# config :people, http_port: 4000

config :memberships, Memberships.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "memberships_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 20

# Configure the sandbox
config :memberships, :sql_sandbox, true

# config :people, http_port: 4000

config :payments, Payments.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "payments_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 20

# Configure the sandbox
config :payments, :sql_sandbox, true

config :payments, Oban, testing: :manual, log: :debug

config :memberships, Oban, testing: :manual, log: :debug
