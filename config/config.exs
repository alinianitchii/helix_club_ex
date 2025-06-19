import Config

config :people, ecto_repos: [People.Infrastructure.Db.Repo]
config :memberships, ecto_repos: [Memberships.Infrastructure.Db.Repo]
config :payments, ecto_repos: [Payments.Infrastructure.Db.Repo]

config :payments, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10],
  repo: Payments.Infrastructure.Db.Repo

config :memberships, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10],
  repo: Memberships.Infrastructure.Db.Repo

import_config "#{config_env()}.exs"
