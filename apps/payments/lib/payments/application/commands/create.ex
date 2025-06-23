defmodule Payments.Application.Commands.Create do
  alias Payments.Domain.PaymentAggregate.PendingPaymentCreated
  alias Payments.Domain.PaymentAggregate
  alias Payments.Infrastructure.Repositories.PaymentsWriteRepo

  def execute(args) do
    command = %PaymentAggregate.Create{
      id: args["id"],
      due_date: Date.from_iso8601!(args["due_date"]),
      amount: args["amount"],
      customer_id: args["customer_id"],
      product_id: args["product_id"]
    }

    with {:ok, payment, event} <- PaymentAggregate.evolve(nil, command),
         {:ok, _} <- PaymentsWriteRepo.save_and_publish(payment, [event]),
         :ok <- publish_integration_event(event) do
      # it might not return the id
      {:ok, payment.id}
    end
  end

  defp publish_integration_event(%PendingPaymentCreated{} = event) do
    int_event = %{
      name: "payment.status-changed",
      type: :event,
      payload: %{
        payment_id: event.id,
        product_id: event.product_id,
        status: event.status,
        previous_status: nil
      }
    }

    PubSub.Integration.EventBus.publish(int_event)
  end
end
