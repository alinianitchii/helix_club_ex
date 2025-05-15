defmodule People.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias People.Infrastructure.Database.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import People.DataCase
    end
  end

  setup tags do
    # Start a sandboxed transaction
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(People.Infrastructure.Database.Repo)

    # Set the sandbox mode based on the test tags
    if tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Database.Repo, {:shared, self()})
    else
      Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Database.Repo, :manual)
    end

    :ok
  end
end


#defmodule People.DataCase do
#  @moduledoc """
#  This module defines the setup for tests requiring
#  access to the application's data layer.
#  """
#
#  use ExUnit.CaseTemplate
#
#  using do
#    quote do
#      alias People.Infrastructure.Database.Repo
#
#      import Ecto
#      import Ecto.Changeset
#      import Ecto.Query
#      import People.DataCase
#
#      # and any other stuff
#    end
#  end
#
#  setup tags do
#    pid =
#      Ecto.Adapters.SQL.Sandbox.start_owner!(People.Infrastructure.Database.Repo,
#        shared: not tags[:async]
#      )
#
#    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
#    :ok
#  end
#end
#
