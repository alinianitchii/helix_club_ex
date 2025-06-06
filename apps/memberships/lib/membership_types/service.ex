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
  end

  def update_membership_type(%MembershipType{} = mt, attrs) do
    mt
    |> MembershipType.changeset(attrs)
    |> Repo.update()
  end

  def archive_membership_type(%MembershipType{} = mt) do
    update_membership_type(mt, %{archived: true})
  end
end
