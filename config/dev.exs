import Config

config :logger, level: :debug

config :people, People.Infrastructure.Db.Repo,
  database: "people_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :memberships, Memberships.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "memberships_test",
  hostname: "localhost"

config :payments, Payments.Infrastructure.Db.Repo,
  username: "postgres",
  password: "postgres",
  database: "payments_test",
  hostname: "localhost"
