defmodule Memberships.Application.Command.SubmitApplication do
  alias Memberships.Domain.MembershipAggregate
  alias Memberships.Domain.Commands
  alias Memberships.Infrastructure.Repositories.MembershipWriteRepo
  alias Memberships.MembershipTypes

  def execute(args) do
    with {:ok, command} <- create_valid_command(args),
         {:ok, membership, event} <- MembershipAggregate.evolve(nil, command),
         {:ok, _} <- MembershipWriteRepo.save_and_publish(membership, [event]) do
      {:ok, membership.id}
    end
  end

  defp create_valid_command(%{
         "id" => id,
         "person_id" => person_id,
         "membership_type_id" => membership_type_id,
         "start_date" => start_date
       }) do
    with {:ok, parsed_start_date} <- Date.from_iso8601(start_date),
         {:ok, membership_type} <- MembershipTypes.get_membership_type(membership_type_id) do
      {:ok,
       %Commands.SubmitFreeApplication{
         id: id,
         person_id: person_id,
         membership_type_id: membership_type_id,
         type: membership_type.type,
         start_date: parsed_start_date
       }}
    end
  end
end
