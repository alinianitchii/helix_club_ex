defmodule Payments.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Payments.Infrastructure.Db.Repo

      use Oban.Testing, repo: Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Payments.DataCase
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Payments.Infrastructure.Db.Repo)
  end

  setup tags do
    pid =
      Ecto.Adapters.SQL.Sandbox.start_owner!(Payments.Infrastructure.Db.Repo,
        shared: not tags[:async]
      )

    on_exit(fn ->
      Process.sleep(100)
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
    end)

    :ok
  end
end
