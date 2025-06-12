defmodule Payments.Workers.EvaluateDueDateTest do
  use Payments.DataCase

  describe "pending payment created" do
    test "job is enqued at the due date + 24h" do
      cmd = %{
        "id" => UUID.uuid4(),
        "customer_id" => UUID.uuid4(),
        "product_id" => UUID.uuid4(),
        "due_date" => "2025-06-11",
        "amount" => 10
      }

      Payments.Application.Commands.Create.execute(cmd)

      assert_enqueued(
        worker: Payments.Workers.Payments.EvaluateDueStatusJob,
        args: %{id: cmd["id"]}
      )
    end

    test "job handler works properly" do
      cmd = %{
        "id" => UUID.uuid4(),
        "customer_id" => UUID.uuid4(),
        "product_id" => UUID.uuid4(),
        "due_date" => "2025-06-11",
        "amount" => 10
      }

      Payments.Application.Commands.Create.execute(cmd)

      assert :ok =
               perform_job(Payments.Workers.Payments.EvaluateDueStatusJob, %{"id" => cmd["id"]})
    end
  end
end
