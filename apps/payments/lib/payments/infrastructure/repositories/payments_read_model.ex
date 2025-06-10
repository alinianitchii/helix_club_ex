defmodule Payments.Infrastructure.Repositories.PaymentsReadRepo do
  # alias Payments.Infrastructure.Db.Schema.PaymentReadModel
  # alias Payments.Infrastructure.Db.Repo

  require Logger

  # def upsert(attrs) do
  #  changeset =
  #    case Repo.get(PaymentReadModel, attrs.id) do
  #      nil -> %PaymentReadModel{id: attrs.id}
  #      existing -> existing
  #    end
  #    |> PaymentReadModel.changeset(attrs)

  #  Repo.insert_or_update(changeset)
  # end

  def get_by_id(id) do
    nil
    # Repo.get(MembershipReadModel, id)
  end
end
