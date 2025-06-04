defmodule People.Infrastructure.Repository.PersonWriteRepoTest do
  use ExUnit.Case, async: false
  use People.DataCase

  alias People.Domain.PersonAggregate
  alias People.Domain.FullNameValueObject
  alias People.Domain.EmailValueObject
  alias People.Domain.BirthDateValueObject
  alias People.Infrastructure.Repository.PersonWriteRepo
  alias People.Infrastructure.Db.Schema.PersonWriteModel
  alias People.Infrastructure.Db.Repo

  setup do
    person = %PersonAggregate{
      id: "test_person_#{:rand.uniform(1_000_000)}",
      full_name: %FullNameValueObject{name: "Ciccio", surname: "Pasticcio"},
      email: %EmailValueObject{value: "ciccio.pasticcio@example.com"},
      date_of_birth: %BirthDateValueObject{value: ~D[1990-01-01]}
    }

    People.EventBus.subscribe("person_domain_events")

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
      assert db_person.state["full_name"]["name"] == "Ciccio"
      assert db_person.state["full_name"]["surname"] == "Pasticcio"
      assert db_person.state["email"]["value"] == "ciccio.pasticcio@example.com"

      assert db_person.version == 2
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
      assert retrieved_person.full_name.name == "Ciccio"
      assert retrieved_person.full_name.surname == "Pasticcio"
      assert retrieved_person.email.value == "ciccio.pasticcio@example.com"
      assert retrieved_person.date_of_birth.value == ~D[1990-01-01]
    end

    test "should return error when person doesn't exist" do
      result = PersonWriteRepo.get("non_existent_id")

      assert result == {:error, :not_found}
    end
  end
end
