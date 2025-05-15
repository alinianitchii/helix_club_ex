defmodule People.Domain.AddressValueObject do
  defstruct [
    :street,
    :number,
    :city,
    :postal_code,
    :state_or_province,
    :country
  ]

  # TODO validate
  def new(street, number, city, postal_code, state_or_province, country) do
    {:ok,
     %__MODULE__{
       street: street,
       number: number,
       city: city,
       postal_code: postal_code,
       state_or_province: state_or_province,
       country: country
     }}
  end
end
