defmodule Memberships.Domain.Events do
  defmodule FreeMembershipApplicationSubmitted do
    @derive Jason.Encoder
    defstruct [
      :id,
      :person_id,
      :type,
      :membership_type_id,
      :start_date,
      :end_date,
      :med_cert_status,
      :status
    ]
  end

  defmodule PaidMembershipApplicationSubmitted do
    @derive Jason.Encoder
    defstruct [
      :id,
      :person_id,
      :type,
      :membership_type_id,
      :start_date,
      :end_date,
      :price,
      :med_cert_status,
      :payment_status,
      :status
    ]
  end
end
