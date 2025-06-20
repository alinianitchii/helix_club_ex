defmodule Memberships.Application.Command.Activate do
  alias Memberships.Domain.MembershipAggregate
  alias Memberships.Domain.Commands
  alias Memberships.Infrastructure.Repositories.MembershipWriteRepo

  def execute(args) do
    with {:ok, membership} <- MembershipWriteRepo.get(args["id"]),
         {:ok, command} <- create_cmd(),
         {:ok, membership, event} <- MembershipAggregate.evolve(membership, command),
         {:ok, _} <- MembershipWriteRepo.save_and_publish(membership, [event]) do
      :ok
    end
  end

  def create_cmd(), do: {:ok, %Commands.Activate{}}
end
