defmodule Payments.Workers.Payments.PaymentDueDateScheduler do
  alias Payments.Workers.Payments.EvaluateDueStatusJob
  alias Payments.Domain.PaymentAggregate.{PendingPaymentCreated}

  def handle(%PendingPaymentCreated{id: id, due_date: due_date}) do
    EvaluateDueStatusJob.new(
      %{id: id},
      scheduled_at: due_date
    )
    |> Oban.insert()
  end

  def handle(_), do: nil
end
