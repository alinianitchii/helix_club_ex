defmodule Memberships.Application.Command.SubmitApplication do
  alias Memberships.Domain.MembershipAggregate
  alias Memberships.Domain.Commands
  alias Memberships.Infrastructure.Repositories.MembershipWriteRepo
  alias Memberships.MembershipTypes

  def execute(args) do
    with {:ok, membership_type} = MembershipTypes.get_membership_type(args["membership_type_id"]),
         {:ok, command} <- create_cmd(args, membership_type),
         {:ok, membership, event} <- MembershipAggregate.evolve(nil, command),
         {:ok, _} <- MembershipWriteRepo.save_and_publish(membership, [event]) do
      :ok
    end
  end

  def create_cmd(
        %{
          "id" => id,
          "person_id" => person_id,
          "start_date" => start_date
        },
        membership_type
      ) do
    with {:ok, parsed_date} <- Date.from_iso8601(start_date) do
      common_args = %{
        id: id,
        person_id: person_id,
        membership_type_id: membership_type.id,
        type: membership_type.type,
        start_date: parsed_date
      }

      case membership_type.price do
        nil ->
          {:ok, struct(Commands.SubmitFreeApplication, common_args)}

        price when is_number(price) ->
          {:ok, struct(Commands.SubmitPaidApplication, Map.put(common_args, :price, price))}
      end
    end
  end
end
