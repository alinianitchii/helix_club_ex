defmodule Memberships.Domain.StatusValueObjectTest do
  use ExUnit.Case

  alias Memberships.Domain.StatusValueObject

  describe "new" do
    test "default status" do
      {:ok, vo} = StatusValueObject.new()

      assert vo.status == :pending
    end
  end

  describe "change" do
    setup do
      {:ok, vo} = StatusValueObject.new()
      %{default: vo}
    end

    test "to a not existing state", %{default: default} do
      {:error, reason} = StatusValueObject.change(default, :gìfoo)

      assert reason == DomainError.new(:invalid_value, "Invalid membership status value")
    end

    test "from pending to activated", %{default: default} do
      {:ok, vo} = StatusValueObject.change(default, :activated)

      assert vo.status == :activated
    end

    test "from pending to suspended", %{default: default} do
      {:error, reason} = StatusValueObject.change(default, :suspended)

      assert reason ==
               DomainError.new(
                 :invalid_state,
                 "Invalid state transition from pending to suspended"
               )
    end

    test "from activated to pending", %{default: pending} do
      {:error, reason} =
        pending
        |> StatusValueObject.change(:activated)
        |> StatusValueObject.change(:pending)

      assert reason ==
               DomainError.new(
                 :invalid_state,
                 "Invalid state transition to pending"
               )
    end
  end
end
