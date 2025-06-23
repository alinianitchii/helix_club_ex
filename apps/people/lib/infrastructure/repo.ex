defmodule People.Infrastructure.Db.Repo do
  use Ecto.Repo,
    otp_app: :people,
    adapter: Ecto.Adapters.Postgres
end
