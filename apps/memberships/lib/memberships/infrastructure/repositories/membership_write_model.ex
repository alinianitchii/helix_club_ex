defmodule Memberships.Infrastructure.Repositories.MembershipWriteRepo do
  alias Memberships.Domain.MedicalCertificateStatusValueObject
  alias Memberships.Domain.DurationValueObject
  alias Memberships.Domain.PriceValueObject
  alias Memberships.Domain.StatusValueObject

  alias Memberships.Domain.PaymentStatusValueObject

  alias Memberships.Domain.MembershipAggregate
  alias Memberships.Infrastructure.Db.Schema.MembershipWriteModel
  alias Memberships.Infrastructure.Db.Repo

  def get(id) do
    case Repo.get(MembershipWriteModel, id) do
      nil ->
        {:error, :not_found}

      schema ->
        aggregate = deserialize_aggregate(schema.state)
        {:ok, aggregate}
    end
  end

  def save(membership, events) when is_list(events) do
    membership_json = serialize_aggregate(membership)

    membership_changeset =
      case Repo.get(MembershipWriteModel, membership.id) do
        nil ->
          %MembershipWriteModel{id: membership.id}
          |> MembershipWriteModel.changeset(%{state: membership_json})

        existing ->
          existing
          |> MembershipWriteModel.changeset(%{state: membership_json})
      end

    Repo.insert_or_update(membership_changeset)
  end

  def save(membership), do: save(membership, [])

  def save_and_publish(membership, events) do
    case save(membership) do
      {:ok, _} ->
        Enum.each(events, &Memberships.EventBus.publish/1)
        {:ok, membership}

      error ->
        error
    end
  end

  # TODO handle nil values for price and payment
  defp serialize_aggregate(membership) do
    %{
      "id" => membership.id,
      "person_id" => membership.person_id,
      "duration" => %{
        "type" => Atom.to_string(membership.duration.type),
        "start_date" => Date.to_iso8601(membership.duration.start_date),
        "end_date" => Date.to_iso8601(membership.duration.end_date)
      },
      # "price" => %{
      #  "value" => membership.price.value
      # },
      # "payment" => %{
      #  "status" => membership.payment.status
      # },
      "med_cert" => %{
        "status" => membership.med_cert.status
      },
      "status" => %{
        "status" => membership.status.status
      }
    }
  end

  defp deserialize_aggregate(json) do
    %MembershipAggregate{
      id: json["id"],
      person_id: json["person_id"],
      duration: struct(DurationValueObject, json["duration"]),
      membership_type_id: json["membership_type_id"],
      price: struct(PriceValueObject, json["price"]),
      payment: struct(PaymentStatusValueObject, json["payment"]),
      med_cert: struct(MedicalCertificateStatusValueObject, json["med_cert"]),
      status: struct(StatusValueObject, json["status"])
    }
  end

  # defp deserialize_date(nil), do: nil
  # defp deserialize_date(date_string), do: Date.from_iso8601!(date_string)
end
