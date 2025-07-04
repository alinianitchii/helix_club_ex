import Config

config :logger, level: :debug

config :people, People.Infrastructure.Db.Repo, url: System.fetch_env!("DATABASE_URL")

config :memberships, Memberships.Infrastructure.Db.Repo, url: System.fetch_env!("DATABASE_URL")

config :payments, Payments.Infrastructure.Db.Repo, url: System.fetch_env!("DATABASE_URL")
