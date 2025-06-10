defmodule Payments.Application.Commands.Create do
  alias Payments.Domain.PaymentAggregate

  def execute(args) do
    command = %PaymentAggregate.Create{
      id: args["id"],
      due_date: args["due_date"],
      amount: args["amount"],
      customer_id: args["customer_id"],
      product_id: args["product_id"]
    }

    with {:ok, payment, event} <-
           PaymentsAggregate.evolve(nil, command) do
      # {:ok, _} <- PaymentsWriteRepo.save_and_publish(payment, [event]) do
      # it might not return the id
      {:ok, payment.id}
    end
  end
end
