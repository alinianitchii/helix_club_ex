defmodule Payments.Workers.Payments.PaymentDueDateScheduler do
  alias Payments.Workers.Payments.EvaluateDueStatusJob
  alias Payments.Domain.PaymentAggregate.{PendingPaymentCreated}

  def handle(%PendingPaymentCreated{id: id, due_date: due_date}) do
    EvaluateDueStatusJob.new(
      %{"id" => id},
      queue: "payment_due_evaluation",
      # WIP
      scheduled_at: DateTime.new!(due_date, Time.add(Time.utc_now(), 1))
    )
    |> Oban.insert()
  end

  def handle(_), do: nil
end
