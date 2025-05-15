defmodule People.Domain.Events do
  @moduledoc "Events that can be produced by the Person aggregate"

  defmodule PersonCreated do
    @derive Jason.Encoder
    defstruct [:id, :name, :surname, :email, :date_of_birth]
  end

  defmodule PersonAddressChanged do
    @derive Jason.Encoder
    defstruct [
      :id,
      :street,
      :number,
      :city,
      :postal_code,
      :state_or_province,
      :country
    ]
  end
end
