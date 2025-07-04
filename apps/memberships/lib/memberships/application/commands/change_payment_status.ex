defmodule Memberships.Application.Commands.ChangePaymentStatus do
  alias Memberships.Domain.MembershipAggregate
  alias Memberships.Domain.Commands
  alias Memberships.Infrastructure.Repositories.MembershipWriteRepo

  def execute(args) do
    with {:ok, membership} <- MembershipWriteRepo.get(args["id"]),
         {:ok, command} <- create_cmd(args["payment_new_status"]),
         {:ok, membership, event} <- MembershipAggregate.evolve(membership, command),
         {:ok, _} <- MembershipWriteRepo.save_and_publish(membership, [event]) do
      :ok
    end
  end

  defp create_cmd(status) do
    {:ok, %Commands.ChangePaymentStatus{status: String.to_atom(status)}}
  end
end
