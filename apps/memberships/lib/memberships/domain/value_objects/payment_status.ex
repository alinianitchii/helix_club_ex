defmodule Memberships.Domain.PaymentStatusValueObject do
  defstruct [:status]

  @valid_statuses [:incomplete, :pending, :overdue, :paid]

  def new(), do: {:ok, %__MODULE__{status: :incomplete}}

  def change(new_status) when new_status not in @valid_statuses do
    {:error, %DomainError{code: :invalid_value, message: "Invalid payment status"}}
  end

  # I may enforce the status changes order
  def change(new_status), do: {:ok, %__MODULE__{status: new_status}}

  def is_paid?(%__MODULE__{status: status}) do
    status == :paid
  end

  def all_statuses(), do: @valid_statuses
end
