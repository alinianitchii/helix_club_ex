defmodule Memberships.Domain.Events do
  defmodule FreeMembershipApplicationSubmitted do
    @derive Jason.Encoder
    defstruct [:id, :person_id, :type, :membership_type_id, :start_date, :end_date]
  end

  defmodule PaidMembershipApplicationSubmitted do
    @derive Jason.Encoder
    defstruct [:id, :person_id, :type, :membership_type_id, :start_date, :end_date, :price]
  end
end
