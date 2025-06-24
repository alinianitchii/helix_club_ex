defmodule Memberships.Application.Commands.ChangeMedicalCertificateStatus do
  alias Memberships.Domain.MembershipAggregate
  alias Memberships.Domain.Commands
  alias Memberships.Infrastructure.Repositories.MembershipWriteRepo

  def execute(args) do
    with {:ok, membership} <- MembershipWriteRepo.get(args["id"]),
         {:ok, command} <- create_cmd(args["med_cert_new_status"]),
         {:ok, membership, event} <- MembershipAggregate.evolve(membership, command),
         {:ok, _} <- MembershipWriteRepo.save_and_publish(membership, [event]) do
      :ok
    end
  end

  defp create_cmd(status), do: {:ok, %Commands.ChangeMedicalCertificateStatus{status: status}}
end
