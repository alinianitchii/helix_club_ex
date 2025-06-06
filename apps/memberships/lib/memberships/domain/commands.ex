defmodule Memberships.Domain.Commands do
  defmodule Create do
    @enforce_keys [:id]
    defstruct [:id, :person_id, :type, :membership_type_id, :start_date]
  end
end
