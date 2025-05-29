defmodule Memberships.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Memberships.Infrastructure.Db.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Memberships.DataCase
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Memberships.Infrastructure.Db.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Memberships.Infrastructure.Db.Repo, :manual)
  end

  setup tags do
    pid =
      Ecto.Adapters.SQL.Sandbox.start_owner!(Memberships.Infrastructure.Db.Repo,
        shared: not tags[:async]
      )

    on_exit(fn ->
      Process.sleep(100)
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
    end)

    :ok
  end
end
