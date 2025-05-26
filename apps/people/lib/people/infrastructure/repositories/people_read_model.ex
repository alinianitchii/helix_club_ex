defmodule People.Infrastructure.Repository.PersonReadRepo do
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

    # Notify test processes if we're in test environment
    if Mix.env() == :test do
      send(:test_process, {:read_model_updated, attrs.id})
    end
  end

  def get_person(id) do
    Repo.get(PersonReadModel, id)
  end
end
