defmodule Payments.Integration.Commands.CreatePayment do
  @derive Jason.Encoder
  defstruct [
    :id,
    :due_date,
    :amount,
    :customer_id,
    :product_id
  ]
end
