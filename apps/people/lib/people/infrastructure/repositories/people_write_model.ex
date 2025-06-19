defmodule People.Infrastructure.Repository.PeopleWriteRepo do
  alias People.Domain.PersonAggregate

  alias People.Infrastructure.Db.Repo
  alias People.Infrastructure.Db.Schema.PersonWriteModel

  alias People.Infrastructure.Outbox

  def get(id) do
    case Repo.get(PersonWriteModel, id) do
      nil ->
        {:error, :not_found}

      person_schema ->
        person = deserialize_aggregate(person_schema.state)
        {:ok, person}
    end
  end

  def save(person) do
    person_json = serialize_aggregate(person)

    person_changeset =
      case Repo.get(PersonWriteModel, person.id) do
        nil ->
          %PersonWriteModel{id: person.id}
          |> PersonWriteModel.changeset(%{state: person_json})

        existing ->
          existing
          |> PersonWriteModel.changeset(%{state: person_json})
      end

    Repo.insert_or_update(person_changeset)
  end

  def save_and_publish(person, events) do
    Repo.transaction(fn ->
      case save(person) do
        {:ok, _} ->
          outbox_entries =
            Enum.map(events, fn event ->
              %{
                type: "event",
                topic: "person.created",
                payload: Map.from_struct(event)
              }
            end)

          {count, _} = Outbox.enqueue_many(outbox_entries)

          case count == length(events) do
            false -> Repo.rollback(:outbox_insert_failed)
            true -> {:ok, person}
          end

        {:error, _} ->
          Repo.rollback(:save_and_publish_failed)
      end
    end)
  end

  defp serialize_aggregate(person) do
    %{
      "id" => person.id,
      "full_name" => %{
        "name" => person.full_name.name,
        "surname" => person.full_name.surname
      },
      "email" => %{
        "value" => person.email.value
      },
      "date_of_birth" => %{
        "value" => Date.to_iso8601(person.date_of_birth.value)
      },
      "address" => serialize_address(person.address)
    }
  end

  defp serialize_address(nil), do: nil

  defp serialize_address(address) do
    %{
      "street" => address.street,
      "number" => address.number,
      "city" => address.city,
      "postal_code" => address.postal_code,
      "state_or_province" => address.state_or_province,
      "country" => address.country
    }
  end

  defp deserialize_aggregate(json) do
    %PersonAggregate{
      id: json["id"],
      full_name: %People.Domain.FullNameValueObject{
        name: json["full_name"]["name"],
        surname: json["full_name"]["surname"]
      },
      email: %People.Domain.EmailValueObject{
        value: json["email"]["value"]
      },
      date_of_birth: %People.Domain.BirthDateValueObject{
        value: deserialize_date(json["date_of_birth"]["value"])
      },
      address: deserialize_address(json["address"])
    }
  end

  defp deserialize_date(nil), do: nil
  defp deserialize_date(date_string), do: Date.from_iso8601!(date_string)

  defp deserialize_address(nil), do: nil

  defp deserialize_address(json) do
    %People.Domain.AddressValueObject{
      street: json["street"],
      number: json["number"],
      city: json["city"],
      postal_code: json["postal_code"],
      state_or_province: json["state_or_province"],
      country: json["country"]
    }
  end
end
