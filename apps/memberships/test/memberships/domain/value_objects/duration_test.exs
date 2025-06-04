defmodule Memberships.Domain.DurationValueObjectTest do
  use ExUnit.Case

  alias Memberships.Domain.DurationValueObject

  describe "new/2" do
    test "unknown type" do
      {:error, reason} = DurationValueObject.new(:unknown, ~D[2026-05-31])

      assert reason == %DomainError{
               code: :invalid_type,
               message: "Invalid duration type",
               http_error_code: :unprocessable_entity
             }
    end

    test "nil start date" do
      {:error, reason} = DurationValueObject.new(:yearly, nil)

      assert reason == %DomainError{
               code: :invalid_date,
               message: "Invalid start date",
               http_error_code: :unprocessable_entity
             }
    end

    test "not a date start date" do
      {:error, reason} = DurationValueObject.new(:yearly, "21-03-2023")

      assert reason == %DomainError{
               code: :invalid_date,
               message: "Invalid start date",
               http_error_code: :unprocessable_entity
             }
    end

    test "end date evaluation with annual type" do
      {:ok, duration_value_object} = DurationValueObject.new(:yearly, ~D[2024-01-01])

      assert duration_value_object.end_date == ~D[2024-12-31]
    end

    test "end date evaluation with quarterly type" do
      {:ok, duration_value_object} = DurationValueObject.new(:quarterly, ~D[2024-01-01])

      assert duration_value_object.end_date == ~D[2024-04-30]
    end

    test "end date evaluation with montly type" do
      {:ok, duration_value_object} = DurationValueObject.new(:monthly, ~D[2024-01-01])

      assert duration_value_object.end_date == ~D[2024-01-31]
    end
  end
end
