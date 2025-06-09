defmodule Payments.Domain.ValueObjects.Amount do
  defstruct [:value]

  def new(amount) when not is_number(amount) do
    {:error, DomainError.new(:invalid_value, "Amount must be a number")}
  end

  def new(amount) do
    parsed_amount = (amount * 1.0) |> Float.round(2)

    {:ok, %__MODULE__{value: parsed_amount}}
  end
end
