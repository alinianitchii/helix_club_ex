defmodule Payments.Domain.ValueObjects.DueDateTest do
  use ExUnit.Case

  alias Payments.Domain.ValueObjects.DueDate

  describe "create" do
    test "not a date" do
      {:error, reason} = DueDate.new("bod")

      assert reason == DomainError.new(:invalid_value, "Due date must be a valid date")
    end

    test "a date" do
      date = Date.utc_today()
      {:ok, vo} = DueDate.new(date)

      assert vo.date == date
    end
  end
end
