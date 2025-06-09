defmodule Payments.Domain.PaymentAggregate do
  alias Payments.Domain.ValueObjects
  alias Payments.Domain.PaymentAggregate
  defstruct [:id, :amount, :due_date, :status]

  defmodule Create do
    defstruct [:id, :amount, :due_date]
  end

  defmodule PendingPaymentCreated do
    defstruct [:id, :amount, :due_date, :status]
  end

  def decide(nil, %Create{} = command) do
    with {:ok, amount} <- ValueObjects.Amount.new(command.amount) do
      {:ok,
       %PendingPaymentCreated{
         id: command.id,
         amount: amount.value,
         due_date: command.due_date,
         status: :pending
       }}
    end
  end

  def apply_event(nil, %PendingPaymentCreated{} = event) do
    %PaymentAggregate{
      id: event.id,
      amount: %ValueObjects.Amount{value: event.amount}
    }
  end

  def evolve(state, command) do
    with {:ok, event} <- decide(state, command) do
      new_state = apply_event(state, event)
      {:ok, new_state, event}
    end
  end
end
