import Config

config :people, ecto_repos: [People.Infrastructure.Db.Repo]

import_config "#{config_env()}.exs"
