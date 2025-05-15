import Config

config :people, People.Infrastructure.Db.Repo,
  database: "people",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :people, ecto_repos: [People.Infrastructure.Db.Repo]
