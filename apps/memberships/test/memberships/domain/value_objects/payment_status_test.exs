defmodule Memberships.Domain.PaymentStatusValueObjectTest do
  use ExUnit.Case

  alias Memberships.Domain.PaymentStatusValueObject

  describe "new" do
    test "default status" do
      {:ok, payment_status} = PaymentStatusValueObject.new()

      assert payment_status.status == :incomplete
    end
  end

  describe "change" do
    test "to an invalid status" do
      {:error, reason} = PaymentStatusValueObject.change(:boh)

      assert reason == %DomainError{code: :invalid_value, message: "Invalid payment status"}
    end

    test "to a valid status" do
      {:ok, payment_status} = PaymentStatusValueObject.change(:pending)

      assert payment_status.status == :pending
    end
  end
end
