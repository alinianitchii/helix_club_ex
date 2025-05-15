defmodule People.Domain.Commands do

  defmodule Create do
    @enforce_keys [:id]
    defstruct [:id, :name, :surname, :email, :date_of_birth]
  end

  defmodule AddAddress do
    defstruct [
      :street,
      :number,
      :city,
      :postal_code,
      :state_or_province,
      :country
    ]
  end
end
