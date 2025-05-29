defmodule Memberships.Domain.Commands do
  defmodule Create do
    @enforce_keys [:id]
    defstruct [:id, :person_id, :type, :start_date]
  end
end
