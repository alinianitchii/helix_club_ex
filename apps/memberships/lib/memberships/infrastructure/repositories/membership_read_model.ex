defmodule Memberships.Infrastructure.Repositories.MembershipReadRepo do
  alias Memberships.Infrastructure.Db.Schema.MembershipReadModel
  alias Memberships.Infrastructure.Db.Repo

  import Ecto.Query

  require Logger

  def upsert(attrs) do
    changeset =
      case Repo.get(MembershipReadModel, attrs.id) do
        nil -> %MembershipReadModel{id: attrs.id}
        existing -> existing
      end
      |> MembershipReadModel.changeset(attrs)

    Repo.insert_or_update(changeset)
  end

  def get_by_id(id) do
    Repo.get(MembershipReadModel, id)
  end

  def get_by_person_id(person_id) do
    from(m in MembershipReadModel, where: m.person_id == ^person_id)
    |> Repo.all()
  end
end
