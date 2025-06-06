defmodule Memberships.MembershipTypes do
  alias Memberships.Infrastructure.Db.Repo
  alias Memberships.Infrastructure.Db.Schema.MembershipType
  import Ecto.Query

  def list_membership_types, do: Repo.all(from mt in MembershipType, where: mt.archived == false)

  def get_membership_type!(id), do: Repo.get!(MembershipType, id)

  def get_membership_type(id) do
    case Repo.get(MembershipType, id) do
      nil -> {:error, DomainError.new(:not_found, "Membership type not found")}
      membership_type -> {:ok, membership_type}
    end
  end

  def create_membership_type(attrs) do
    %MembershipType{}
    |> MembershipType.changeset(attrs)
    |> Repo.insert()
    |> notify(:created)
  end

  def update_membership_type(%MembershipType{} = mt, attrs) do
    mt
    |> MembershipType.changeset(attrs)
    |> Repo.update()
    |> notify(:updated)
  end

  def archive_membership_type(%MembershipType{} = mt) do
    update_membership_type(mt, %{archived: true})
  end

  defp notify({:ok, %MembershipType{price_id: price_id} = type} = result, :created)
       when not is_nil(price_id) do
    publish_event(:membership_type_price_defined, type)
    result
  end

  defp notify(result, _), do: result

  defp publish_event(:membership_type_price_defined, %MembershipType{id: id, price_id: price_id}) do
    event = %{
      event_name: "MembershipTypePriceDefined",
      data: %{membership_type_id: id, price_id: price_id}
    }

    IO.inspect(event)
    # PubSub.broadcast(MyApp.PubSub, "memberships", {:event, event})
  end
end
