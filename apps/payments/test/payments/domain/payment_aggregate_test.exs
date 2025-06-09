defmodule Payments.Domain.PaymentAggregateTest do
  use ExUnit.Case

  alias Payments.Domain.PaymentAggregate
  alias Payments.Domain.ValueObjects

  describe "create" do
    test "value objects initialization" do
      create_command = %PaymentAggregate.Create{
        id: UUID.uuid4(),
        amount: 20,
        due_date: Date.add(Date.utc_today(), 10)
      }

      {:ok, payment, _} = PaymentAggregate.evolve(nil, create_command)

      assert %ValueObjects.Amount{} = payment.amount
    end
  end
end
