defmodule Memberships.Domain.Events do
  defmodule MembershipCreated do
    @derive Jason.Encoder
    defstruct [:id, :person_id, :type, :start_date, :end_date]
  end
end
