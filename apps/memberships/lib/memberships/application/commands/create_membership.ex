defmodule Memberships.Application.Command.CreateMembership do
  alias Memberships.Domain.MembershipAggregate
  alias Memberships.Domain.Commands
  alias Memberships.Infrastructure.Repositories.MembershipWriteRepo

  def execute(%{"id" => id, "person_id" => person_id, "type" => type, "start_date" => start_date}) do
    {:ok, parsed_start_date} = Date.from_iso8601(start_date)
    type_as_atom = String.to_atom(type)

    command = %Commands.Create{
      id: id,
      person_id: person_id,
      type: type_as_atom,
      start_date: parsed_start_date
    }

    with {:ok, membership, event} <- MembershipAggregate.evolve(nil, command),
         {:ok, _} <- MembershipWriteRepo.save_and_publish(membership, [event]) do
      {:ok, membership.id}
    end
  end
end
