defmodule MedicalCertificates.Infrastructure.Repositories.MedicalCertificatesRepo do
  alias MedicalCertificates.Domain.ValueObjects
  alias People.Domain.FullNameValueObject
  alias MedicalCertificates.Domain.MedicalCertificateAggregate
  alias MedicalCertificates.Infrastructure.Db.Schema.MedicalCertificate
  alias People.Infrastructure.Db.Repo

  def get_by_id(id) do
    Repo.get(MedicalCertificate, id)
  end

  def get_aggregate_by_id(id) do
    case Repo.get(MedicalCertificate, id) do
      nil ->
        {:error, :not_found}

      schema ->
        aggregate = schema_to_aggregate(schema)
        {:ok, aggregate}
    end
  end

  def save(aggregate) do
    schema = aggregate_to_atrs(aggregate)

    case Repo.get(MedicalCertificate, aggregate.id) do
      nil -> %MedicalCertificate{}
      existing -> existing |> MedicalCertificate.changeset(schema)
    end
    |> MedicalCertificate.changeset(schema)
    |> Repo.insert_or_update()
  end

  def save_and_publish(state, events) do
    case save(state) do
      {:ok, _} ->
        Enum.each(events, &MedicalCertificates.EventBus.publish/1)
        {:ok, state}

      error ->
        error
    end
  end

  defp aggregate_to_atrs(aggregate) do
    # Maybe I should not use the schema here
    %{
      id: aggregate.id,
      holder_id: aggregate.holder_id,
      holder_name: aggregate.holder_full_name.name,
      holder_surname: aggregate.holder_full_name.surname,
      request_date: aggregate.request_date.date,
      issue_date: aggregate.validity.issue_date,
      status: aggregate.validity.status
    }
  end

  defp schema_to_aggregate(schema) do
    %MedicalCertificateAggregate{
      id: schema.id,
      holder_id: schema.holder_id,
      holder_full_name: %FullNameValueObject{
        name: schema.holder_name,
        surname: schema.holder_surname
      },
      request_date: %ValueObjects.ReqeustDate{date: schema.request_date},
      validity: %ValueObjects.Validity{issue_date: schema.issue_date, status: schema.status}
    }
  end
end
