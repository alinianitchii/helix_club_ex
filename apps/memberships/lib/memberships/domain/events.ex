defmodule Memberships.Domain.Events do
  defmodule MembershipCreated do
    @derive Jason.Encoder
    defstruct [:id, :person_id, :type, :membership_type_id, :start_date, :end_date]
  end
end
