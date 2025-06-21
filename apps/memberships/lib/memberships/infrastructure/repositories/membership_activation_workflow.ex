defmodule Memberships.Infrastructure.Repositories.MembershipActivationWorkflow do
  alias Memberships.Infrastructure.Db.Repo
  alias Memberships.Infrastructure.Db.Schema.MembershipActivationWorkflow

  require Logger

  def upsert(attrs) do
    changeset =
      case Repo.get(MembershipActivationWorkflow, attrs.process_id) do
        nil -> %MembershipActivationWorkflow{process_id: attrs.process_id}
        existing -> existing
      end
      |> MembershipActivationWorkflow.changeset(attrs)

    Repo.insert_or_update(changeset)
  end

  def get_by_id(id) do
    Repo.get(MembershipActivationWorkflow, id)
  end
end
