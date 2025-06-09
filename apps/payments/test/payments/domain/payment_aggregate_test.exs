defmodule Payments.Domain.PaymentAggregateTest do
  use ExUnit.Case

  alias Payments.Domain.PaymentAggregate
  alias Payments.Domain.ValueObjects

  setup do
    create_command = %PaymentAggregate.Create{
      id: UUID.uuid4(),
      amount: 20,
      due_date: Date.add(Date.utc_today(), 10)
    }

    {:ok, payment, _} = PaymentAggregate.evolve(nil, create_command)

    %{payment: payment}
  end

  describe "created aggregate" do
    test "check value objects initialization", %{payment: payment} do
      assert %ValueObjects.Amount{} = payment.amount
      assert %ValueObjects.DueDate{} = payment.due_date
      assert %ValueObjects.Status{} = payment.status
    end

    test "cancel", %{payment: payment} do
      cancel_cmd = %PaymentAggregate.Cancel{reason: "just because"}

      {:ok, payment, _} = PaymentAggregate.evolve(payment, cancel_cmd)

      assert payment.status.status == :canceled
    end

    test "pay", %{payment: payment} do
      pay_cmd = %PaymentAggregate.Pay{}

      {:ok, payment, _} = PaymentAggregate.evolve(payment, pay_cmd)

      assert payment.status.status == :paid
    end
  end

  describe "evaluate due status pending payment" do
    test "date before expiration" do
      create_command = %PaymentAggregate.Create{
        id: UUID.uuid4(),
        amount: 20,
        due_date: Date.add(Date.utc_today(), 10)
      }

      {:ok, payment, _} = PaymentAggregate.evolve(nil, create_command)

      evaluate_due_status_cmd = %PaymentAggregate.EvaluateDueStatus{}

      {:ok, payment, _} = PaymentAggregate.evolve(payment, evaluate_due_status_cmd)

      assert payment.status.status == :pending
    end

    test "date after expiration" do
      create_command = %PaymentAggregate.Create{
        id: UUID.uuid4(),
        amount: 20,
        due_date: Date.add(Date.utc_today(), -1)
      }

      {:ok, payment, _} = PaymentAggregate.evolve(nil, create_command)

      evaluate_due_status_cmd = %PaymentAggregate.EvaluateDueStatus{}

      {:ok, payment, _} = PaymentAggregate.evolve(payment, evaluate_due_status_cmd)

      assert payment.status.status == :overdue
    end
  end
end
