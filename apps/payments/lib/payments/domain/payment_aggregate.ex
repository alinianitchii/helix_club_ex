defmodule Payments.Domain.PaymentAggregate do
  alias Payments.Domain.ValueObjects
  alias Payments.Domain.PaymentAggregate

  defstruct [:id, :amount, :due_date, :status, :customer_id, :product_id]

  defmodule Create do
    defstruct [:id, :amount, :due_date, :customer_id, :product_id]
  end

  defmodule Pay do
    defstruct []
  end

  defmodule EvaluateDueStatus do
    defstruct []
  end

  defmodule Cancel do
    defstruct [:reason]
  end

  defmodule PendingPaymentCreated do
    defstruct [:id, :amount, :due_date, :status, :customer_id, :product_id]
  end

  defmodule PaymentCashed do
    defstruct [:id, :status, :previous_status, :cashed_date]
  end

  defmodule PaymentOverdue do
    defstruct [:id, :status, :previous_status]
  end

  defmodule PaymentCanceled do
    defstruct [:id, :status, :previous_status, :reason]
  end

  def decide(nil, %Create{} = command) do
    with {:ok, amount} <- ValueObjects.Amount.new(command.amount),
         {:ok, due_date} <- ValueObjects.DueDate.new(command.due_date),
         {:ok, status} <- ValueObjects.Status.new() do
      {:ok,
       %PendingPaymentCreated{
         id: command.id,
         amount: amount.value,
         due_date: due_date.date,
         status: status.status,
         customer_id: command.customer_id,
         product_id: command.product_id
       }}
    end
  end

  def decide(%PaymentAggregate{} = state, %Pay{}) do
    with {:ok, status} = ValueObjects.Status.change(state.status, :paid) do
      {:ok,
       %PaymentCashed{
         id: state.id,
         status: status.status,
         previous_status: state.status.status,
         cashed_date: Date.utc_today()
       }}
    end
  end

  def decide(%PaymentAggregate{} = state, %EvaluateDueStatus{}) do
    cond do
      not ValueObjects.Status.is_status?(state.status, :pending) ->
        {:ok, nil}

      not ValueObjects.Status.is_valid_state_transition?(state.status, :overdue) ->
        {:error, DomainError.new(:invalid_state, "Invalid state transition")}

      Date.after?(Date.utc_today(), state.due_date.date) ->
        {:ok,
         %PaymentOverdue{id: state.id, status: :overdue, previous_status: state.status.status}}

      true ->
        {:ok, nil}
    end
  end

  def decide(%PaymentAggregate{} = state, %Cancel{} = command) do
    with {:ok, status} = ValueObjects.Status.change(state.status, :canceled) do
      {:ok,
       %PaymentCanceled{
         id: state.id,
         status: status.status,
         previous_status: state.status.status,
         reason: command.reason
       }}
    end
  end

  def apply_event(nil, %PendingPaymentCreated{} = event) do
    %PaymentAggregate{
      id: event.id,
      amount: %ValueObjects.Amount{value: event.amount},
      due_date: %ValueObjects.DueDate{date: event.due_date},
      status: %ValueObjects.Status{status: event.status},
      customer_id: event.customer_id,
      product_id: event.product_id
    }
  end

  def apply_event(%PaymentAggregate{} = state, %PaymentCashed{} = event) do
    %PaymentAggregate{
      state
      | status: %ValueObjects.Status{status: event.status}
    }
  end

  def apply_event(%PaymentAggregate{} = state, %PaymentOverdue{} = event) do
    %PaymentAggregate{
      state
      | status: %ValueObjects.Status{status: event.status}
    }
  end

  def apply_event(%PaymentAggregate{} = state, %PaymentCanceled{} = event) do
    %PaymentAggregate{
      state
      | status: %ValueObjects.Status{status: event.status}
    }
  end

  def evolve(state, command) do
    case decide(state, command) do
      {:ok, nil} ->
        # In case of a decision without an event. Is it possible according to decider pattern?
        {:ok, state, nil}

      {:ok, event} ->
        new_state = apply_event(state, event)
        {:ok, new_state, event}
    end
  end
end
