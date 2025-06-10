defmodule Payments.Http.PaymentsTest do
  use ExUnit.Case, async: false

  use Payments.Http.ConnCase

  setup do
    {:ok,
     create_payment_fixture: %{
       # it correspounds to the person
       customer_id: UUID.uuid4(),
       # at the moment it will be memberships but it can be anything
       product_id: UUID.uuid4(),
       amount: 10,
       due_date: "2023-03-23"
     }}
  end

  describe "POST /payments" do
    test "creates a new payment", %{create_payment_fixture: fixture} do
      {:ok, resp} = do_api_call(:post, "/payments", fixture)

      assert resp.status == 201
      assert resp.decoded["id"] != nil
    end
  end
end
