import Config

config :people, People.Infrastructure.Db.Repo,
  database: "people",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
