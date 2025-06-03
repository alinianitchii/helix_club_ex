defmodule Memberships.Infrastructure.Repositories.MembershipReadRepo do
  alias Memberships.Infrastructure.Db.Schema.MembershipReadModel
  alias Memberships.Infrastructure.Db.Repo

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
end
