import Config

config :logger, level: :debug

config :people, People.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "people_dev",
  hostname: "db",
  pool_size: 10

config :memberships, Memberships.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "memberships_dev",
  hostname: "db",
  pool_size: 10

config :payments, Payments.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "payments_dev",
  hostname: "db",
  pool_size: 10
