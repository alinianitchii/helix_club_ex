defmodule People.Infrastructure.Repository.PersonRepositoryTest do
  use People.DataCase
  alias People.Domain.PersonAggregate
  alias People.Domain.PersonFullNameValueObject
  alias People.Domain.EmailValueObject
  alias People.Domain.BirthDateValueObject
  alias People.Infrastructure.Repository.PersonRepository
  alias People.Infrastructure.Database.Schema.PersonSchema
  alias People.Infrastructure.Database.Repo

  setup do
    # Create a sample person aggregate for testing
    person = %PersonAggregate{
      id: "test_person_#{:rand.uniform(1_000_000)}",
      full_name: %PersonFullNameValueObject{name: "John", surname: "Doe"},
      email: %EmailValueObject{value: "john.doe@example.com"},
      date_of_birth: %BirthDateValueObject{value: ~D[1990-01-01]}
    }

    # Subscribe the current test process to the pubsub topic
    Phoenix.PubSub.subscribe(People.PubSub, "person_domain_events")

    {:ok, %{person: person}}
  end

  describe "save/1" do
    test "should save person to database as JSON", %{person: person} do
      # Act
      {:ok, saved_person} = PersonRepository.save(person)

      # Assert - Check the person was saved correctly
      assert saved_person.id == person.id

      # Verify in database
      db_person = Repo.get!(PersonSchema, person.id)
      assert db_person.id == person.id

      # Verify the state was saved as JSON
      assert is_map(db_person.state)
      assert db_person.state["id"] == person.id
      assert db_person.state["full_name"]["name"] == "John"
      assert db_person.state["full_name"]["surname"] == "Doe"
      assert db_person.state["email"]["value"] == "john.doe@example.com"

      # Check version
      assert db_person.version == 1
    end
  end

  describe "save_and_publish/2" do
    test "publishes event" do
      # Create a sample person aggregate
      person = %PersonAggregate{
        id: UUID.uuid4(),
        full_name: %People.Domain.PersonFullNameValueObject{name: "Alin", surname: "Ianitchii"},
        email: %People.Domain.EmailValueObject{value: "alin@example.com"},
        date_of_birth: %People.Domain.BirthDateValueObject{value: ~D[2000-01-01]},
        address: nil
      }

      event = %PersonAggregate.Events.PersonCreated{
        id: person.id,
        name: "Alin",
        surname: "Ianitchii",
        email: "alin@example.com",
        date_of_birth: ~D[2000-01-01]
      }

      {:ok, _saved_person} = PersonRepository.save_and_publish(person, [event])

      # Assert that the event was published and received
      assert_receive ^event, 500
    end
  end

  describe "get/1" do
    test "should retrieve a person by ID", %{person: person} do
      # Arrange
      {:ok, _} = PersonRepository.save(person)

      # Act
      {:ok, retrieved_person} = PersonRepository.get(person.id)

      # Assert
      assert retrieved_person.id == person.id
      assert retrieved_person.full_name.name == "John"
      assert retrieved_person.full_name.surname == "Doe"
      assert retrieved_person.email.value == "john.doe@example.com"
      assert retrieved_person.date_of_birth.value == ~D[1990-01-01]
    end

    test "should return error when person doesn't exist" do
      # Act
      result = PersonRepository.get("non_existent_id")

      # Assert
      assert result == {:error, :not_found}
    end
  end
end
