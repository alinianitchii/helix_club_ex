defmodule Memberships.Domain.PriceValueObjectTest do
  use ExUnit.Case

  alias Memberships.Domain.PriceValueObject

  describe "new/1" do
    test "positive value" do
      {:ok, vo} = PriceValueObject.new(100)

      assert vo.value == 100
    end

    test "negative value" do
      {:error, reason} = PriceValueObject.new(-10)

      assert reason == %DomainError{
               code: :invalid_value,
               message: "Invalid price",
               http_error_code: :unprocessable_entity
             }
    end

    test "invalid number" do
      {:error, reason} = PriceValueObject.new("10")

      assert reason == %DomainError{
               code: :invalid_value,
               message: "Not a valid number",
               http_error_code: :unprocessable_entity
             }
    end
  end
end
