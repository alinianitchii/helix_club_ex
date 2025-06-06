defmodule Memberships.Domain.PriceValueObject do
  defstruct [:value]

  def new(value) when not is_number(value),
    do: {:error, DomainError.new(:invalid_value, "Not a valid number")}

  def new(value) when value < 0, do: {:error, DomainError.new(:invalid_value, "Invalid price")}

  def new(value), do: {:ok, %__MODULE__{value: value}}
end
