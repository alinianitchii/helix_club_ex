defmodule People.Infrastructure.Repository.PersonWriteRepo do
  @moduledoc """
  Repository for Person aggregate with JSON storage and outbox pattern support.
  """

  alias People.Domain.PersonAggregate
  alias People.Domain.Events.PersonCreated
  alias People.Domain.Events.PersonAddressChanged
  alias People.Infrastructure.Db.Repo
  alias People.Infrastructure.Db.Schema.PersonWriteModel
  alias People.Infrastructure.Db.Schema.OutboxSchema

  @doc """
  Retrieves a person by ID, rebuilding the aggregate from JSON.
  """
  def get(id) do
    case Repo.get(PersonWriteModel, id) do
      nil ->
        {:error, :not_found}

      person_schema ->
        # Deserialize the state from JSON to the aggregate
        person = deserialize_aggregate(person_schema.state)
        {:ok, person}
    end
  end

  @doc """
  Saves the person aggregate and outbox events in a single transaction.
  Uses JSON storage for the aggregate state.
  """
  def save(person, events) when is_list(events) do
    Repo.transaction(fn ->
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

      case Repo.insert_or_update(person_changeset) do
        {:ok, _saved_person} ->
          outbox_entries =
            Enum.map(events, fn event ->
              %{
                aggregate_id: person.id,
                aggregate_type: "Person",
                event_type: event_type_for(event),
                payload: serialize_event(event),
                metadata: %{},
                created_at: DateTime.utc_now()
              }
            end)

          {count, _} = Repo.insert_all(OutboxSchema, outbox_entries)

          if count == length(events) do
            person
          else
            Repo.rollback(:outbox_insert_failed)
          end

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def save_and_publish(person, events) do
    case save(person) do
      {:ok, _person} ->
        Enum.each(events, &People.EventBus.publish/1)
        {:ok, person}

      error ->
        error
    end
  end

  def save(person), do: save(person, [])

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

  defp serialize_event(event) do
    case event do
      %PersonCreated{} = e ->
        %{
          "id" => e.id,
          "name" => e.name,
          "surname" => e.surname,
          "email" => e.email,
          "date_of_birth" => Date.to_iso8601(e.date_of_birth)
        }

      %PersonAddressChanged{} = e ->
        %{
          "id" => e.id,
          "street" => e.street,
          "number" => e.number,
          "city" => e.city,
          "postal_code" => e.postal_code,
          "state_or_province" => e.state_or_province,
          "country" => e.country
        }
    end
  end

  defp event_type_for(%PersonCreated{}), do: "person_created"

  defp event_type_for(%PersonAddressChanged{}),
    do: "person_address_changed"

  # Add more event type mappings as needed
end
