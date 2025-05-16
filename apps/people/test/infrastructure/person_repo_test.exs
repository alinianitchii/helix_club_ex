defmodule People.Infrastructure.Repository.PersonWriteRepoTest do
  use ExUnit.Case, async: false
  use People.DataCase

  alias People.Domain.PersonAggregate
  alias People.Domain.FullNameValueObject
  alias People.Domain.EmailValueObject
  alias People.Domain.BirthDateValueObject
  alias People.Infrastructure.Repository.PersonWriteRepo
  alias People.Infrastructure.Db.Schema.PersonWriteModel
  alias People.Infrastructure.Db.Schema.OutboxSchema
  alias People.Infrastructure.Db.Repo


  setup do
    # Create a sample person aggregate for testing
    person = %PersonAggregate{
      id: "test_person_#{:rand.uniform(1_000_000)}",
      full_name: %FullNameValueObject{name: "John", surname: "Doe"},
      email: %EmailValueObject{value: "john.doe@example.com"},
      date_of_birth: %BirthDateValueObject{value: ~D[1990-01-01]}
    }

    # Subscribe
    Phoenix.PubSub.subscribe(People.PubSub, "person_domain_events")

    {:ok, %{person: person}}
  end

  describe "save/1" do
    test "should save person to database as JSON", %{person: person} do
      {:ok, saved_person} = PersonWriteRepo.save(person)

      assert saved_person.id == person.id

      db_person = Repo.get!(PersonWriteModel, person.id)
      assert db_person.id == person.id

      assert is_map(db_person.state)
      assert db_person.state["id"] == person.id
      assert db_person.state["full_name"]["name"] == "John"
      assert db_person.state["full_name"]["surname"] == "Doe"
      assert db_person.state["email"]["value"] == "john.doe@example.com"

      assert db_person.version == 2
    end

    test "publishes event from outbox" do
      person = %PersonAggregate{
        id: UUID.uuid4(),
        full_name: %People.Domain.FullNameValueObject{name: "Alin", surname: "Ianitchii"},
        email: %People.Domain.EmailValueObject{value: "alin@example.com"},
        date_of_birth: %People.Domain.BirthDateValueObject{value: ~D[2000-01-01]},
        address: nil
      }

      event = %People.Domain.Events.PersonCreated{
        id: person.id,
        name: "Alin",
        surname: "Ianitchii",
        email: "alin@example.com",
        date_of_birth: ~D[2000-01-01]
      }

      {:ok, _saved_person} = PersonWriteRepo.save(person, [event])

      # Wait for publish to happen (retry/assert eventually)
      assert_receive ^event, 1000

      # Ensure it's marked as published
      [outbox_entry] = Repo.all(from o in OutboxSchema, where: o.aggregate_id == ^person.id)
      assert outbox_entry.published_at != nil
    end
  end

  describe "save_and_publish/2" do
    test "publishes event" do
      person = %PersonAggregate{
        id: UUID.uuid4(),
        full_name: %People.Domain.FullNameValueObject{name: "Alin", surname: "Ianitchii"},
        email: %People.Domain.EmailValueObject{value: "alin@example.com"},
        date_of_birth: %People.Domain.BirthDateValueObject{value: ~D[2000-01-01]},
        address: nil
      }

      event = %People.Domain.Events.PersonCreated{
        id: person.id,
        name: "Alin",
        surname: "Ianitchii",
        email: "alin@example.com",
        date_of_birth: ~D[2000-01-01]
      }

      {:ok, _saved_person} = PersonWriteRepo.save_and_publish(person, [event])

      # Assert that the event was published and received
      assert_receive ^event, 500
    end
  end

  describe "get/1" do
    test "should retrieve a person by ID", %{person: person} do
      {:ok, _} = PersonWriteRepo.save(person)

      {:ok, retrieved_person} = PersonWriteRepo.get(person.id)

      assert retrieved_person.id == person.id
      assert retrieved_person.full_name.name == "John"
      assert retrieved_person.full_name.surname == "Doe"
      assert retrieved_person.email.value == "john.doe@example.com"
      assert retrieved_person.date_of_birth.value == ~D[1990-01-01]
    end

    test "should return error when person doesn't exist" do
      result = PersonWriteRepo.get("non_existent_id")

      assert result == {:error, :not_found}
    end
  end
end
