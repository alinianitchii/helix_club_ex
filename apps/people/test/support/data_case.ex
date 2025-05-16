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

  setup tags do
    # Start a sandboxed transaction
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(People.Infrastructure.Db.Repo)

    # Set the sandbox mode based on the test tags
    if tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Db.Repo, {:shared, self()})
    else
      Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Db.Repo, :manual)
    end

    :ok
  end
end
