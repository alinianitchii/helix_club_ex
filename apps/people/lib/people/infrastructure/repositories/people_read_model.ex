defmodule People.Infrastructure.Repository.PeopleReadRepo do
  alias People.Infrastructure.Db.Schema.PersonReadModel
  alias People.Infrastructure.Db.Repo

  def upsert_person(attrs) do
    changeset =
      case Repo.get(PersonReadModel, attrs.id) do
        nil -> %PersonReadModel{id: attrs.id}
        existing -> existing
      end
      |> PersonReadModel.changeset(attrs)

    Repo.insert_or_update(changeset)
  end

  def get_person(id) do
    Repo.get(PersonReadModel, id)
  end
end
