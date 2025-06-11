defmodule Payments.Application.Command.EvaluateDueStatus do
  alias Payments.Domain.PaymentAggregate
  alias Payments.Domain.PaymentAggregate.{EvaluateDueStatus}
  alias Payments.Infrastructure.Repositories.PaymentsWriteRepo

  def execute(%{"id" => id}) do
    command = %EvaluateDueStatus{}

    case PaymentsWriteRepo.get(id) do
      {:error, :not_found} ->
        {:error, :not_found}

      {:ok, payment} ->
        with {:ok, payment, event} <- PaymentAggregate.evolve(payment, command),
             {:ok, _} <- PaymentsWriteRepo.save_and_publish(payment, [event]) do
          {:ok}
        end
    end
  end
end
