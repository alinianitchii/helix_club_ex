defmodule Payments.Workers.Payments.EvaluateDueStatusJob do
  use Oban.Worker, queue: :default

  alias Payments.Application.Commands.EvaluateDueStatus

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{id: id}}) do
    EvaluateDueStatus.execute(%{"id" => id})
  end
end
