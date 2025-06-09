defmodule Payments.Domain.ValueObjects.DueDate do
  defstruct [:date]

  def new(%Date{} = date) do
    {:ok, %__MODULE__{date: date}}
  end

  def new(_), do: {:error, DomainError.new(:invalid_value, "Due date must be a valid date")}
end
