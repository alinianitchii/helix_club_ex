defmodule Memberships.Infrastructure.Db.Repo do
  use Ecto.Repo,
    otp_app: :memberships,
    adapter: Ecto.Adapters.Postgres
end
