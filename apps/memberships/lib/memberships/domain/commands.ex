defmodule Memberships.Domain.Commands do
  defmodule SubmitFreeApplication do
    @enforce_keys [:id, :person_id]
    defstruct [:id, :person_id, :type, :membership_type_id, :start_date]
  end

  defmodule SubmitPaidApplication do
    @enforce_keys [:id, :person_id, :price]
    defstruct [:id, :person_id, :type, :membership_type_id, :start_date, :price]
  end
end
