import Config

config :logger, level: :debug

config :people, People.Infrastructure.Db.Repo,
  url: "#{System.fetch_env!("DATABASE_URL")}/people_dev"

config :memberships, Memberships.Infrastructure.Db.Repo,
  url: "#{System.fetch_env!("DATABASE_URL")}/memberships_dev"

config :payments, Payments.Infrastructure.Db.Repo,
  url: "#{System.fetch_env!("DATABASE_URL")}/payments_dev"
