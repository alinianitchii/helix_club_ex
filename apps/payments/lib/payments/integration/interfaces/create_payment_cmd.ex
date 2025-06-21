defmodule Payments.Integration.Commands.CreatePayment do
  @derive Jason.Encoder
  defstruct [
    :id,
    :due_date,
    :amount,
    :customer_id,
    :product_id
  ]

  # TODO: add validation
  def new(%{customer_id: customer_id, product_id: product_id, amount: amount, due_date: due_date}) do
    id = UUID.uuid4()

    %__MODULE__{
      id: id,
      due_date: due_date,
      amount: amount,
      customer_id: customer_id,
      product_id: product_id
    }
  end
end
