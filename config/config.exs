import Config

config :people, ecto_repos: [People.Infrastructure.Db.Repo]
config :memberships, ecto_repos: [Memberships.Infrastructure.Db.Repo]
config :payments, ecto_repos: [Payments.Infrastructure.Db.Repo]

import_config "#{config_env()}.exs"
