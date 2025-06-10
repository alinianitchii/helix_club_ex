defmodule Payments.Infrastructure.PaymentsEventSubscriber do
  use GenServer
  require Logger

  alias Payments.Infrastructure.Projectors.PaymentProjector

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    Payments.EventBus.subscribe("payments_domain_events")
    {:ok, %{}}
  end

  def handle_info(event, state) do
    try do
      PaymentProjector.handle(event)
      {:noreply, state}
    rescue
      e in DBConnection.ConnectionError ->
        Logger.error("Database connection error: #{inspect(e)}")
        {:noreply, state}

      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end
end

defmodule Payments.Infrastructure.Projectors.PaymentProjector do
  alias Payments.Infrastructure.Repositories.PaymentsReadRepo

  alias Payments.Domain.PaymentAggregate.{
    PendingPaymentCreated,
    PaymentCashed,
    PaymentOverdue,
    PaymentCanceled
  }

  def handle(%PendingPaymentCreated{} = event) do
    PaymentsReadRepo.upsert(%{
      id: event.id,
      amount: event.amount,
      due_date: event.due_date,
      status: Atom.to_string(event.status),
      customer_id: event.customer_id,
      product_id: event.product_id
    })
  end

  def handle(%PaymentCashed{} = event) do
    PaymentsReadRepo.upsert(%{
      id: event.id,
      status: Atom.to_string(event.status),
      previous_status: Atom.to_string(event.previous_status),
      cashed_date: event.cashed_date
    })
  end

  def handle(%PaymentOverdue{} = event) do
    PaymentsReadRepo.upsert(%{
      id: event.id,
      status: Atom.to_string(event.status),
      previous_status: Atom.to_string(event.previous_status)
    })
  end

  def handle(%PaymentCanceled{} = event) do
    PaymentsReadRepo.upsert(%{
      id: event.id,
      status: Atom.to_string(event.status),
      previous_status: Atom.to_string(event.previous_status),
      cancel_reason: event.reason
    })
  end
end
