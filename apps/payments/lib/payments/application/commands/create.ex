defmodule Payments.IntegrationCommands.CreatePayment do
  @derive Jason.Encoder
  defstruct [
    :id,
    :due_date,
    :amount,
    :customer_id,
    :product_id
  ]
end

defmodule Payments.Application.Commands.Create do
  alias Payments.Domain.PaymentAggregate
  alias Payments.Domain.PaymentAggregate.{Create}
  alias Payments.Infrastructure.Repositories.PaymentsWriteRepo

  def execute(args) do
    command = %Create{
      id: args["id"],
      due_date: Date.from_iso8601!(args["due_date"]),
      amount: args["amount"],
      customer_id: args["customer_id"],
      product_id: args["product_id"]
    }

    with {:ok, payment, event} <- PaymentAggregate.evolve(nil, command),
         {:ok, _} <- PaymentsWriteRepo.save_and_publish(payment, [event]) do
      # it might not return the id
      {:ok, payment.id}
    end
  end
end
