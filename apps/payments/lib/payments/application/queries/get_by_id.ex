defmodule Payments.Application.Queries.GetById do
  alias Payments.Infrastructure.Repositories.PaymentsReadRepo

  def execute(id) do
    case PaymentsReadRepo.get_by_id(id) do
      nil -> {:error, :not_found}
      payment -> {:ok, payment}
    end
  end
end
