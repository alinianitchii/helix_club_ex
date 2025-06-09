defmodule Payments.Domain.ValueObjects.AmountTest do
  use ExUnit.Case

  alias Payments.Domain.ValueObjects.Amount

  describe "new" do
    test "valid amount" do
      {:ok, vo} = Amount.new(20)

      assert vo.value == 20.00
    end

    test "not a number" do
      {:error, reason} = Amount.new("f")

      assert reason == DomainError.new(:invalid_value, "Amount must be a number")
    end
  end
end
