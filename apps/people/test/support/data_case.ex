defmodule People.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      alias People.Infrastructure.Db.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import People.DataCase
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(People.Infrastructure.Db.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Db.Repo, :manual)
  end

  setup tags do
    pid =
      Ecto.Adapters.SQL.Sandbox.start_owner!(People.Infrastructure.Db.Repo,
        shared: not tags[:async]
      )

    on_exit(fn ->
      Process.sleep(100)
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
    end)

    :ok
  end
end
