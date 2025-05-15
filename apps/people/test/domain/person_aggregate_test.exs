defmodule PersonAggregateTest do
  use ExUnit.Case
  doctest People.Domain.PersonAggregate

  alias People.Domain.AddressValueObject
  alias People.Domain.PersonAggregate
  alias People.Domain.PersonAggregate.Commands
  alias People.Domain.PersonAggregate.Events

  describe "create" do
    test "Create a valid person" do
      command = %Commands.Create{
        id: "person_123",
        name: "John",
        surname: "Doe",
        email: "john.doe@example.com",
        date_of_birth: ~D[1990-01-01]
      }

      assert {:ok, person, event} = PersonAggregate.evolve(nil, command)

      assert person.id == "person_123"
      assert person.full_name.name == "John"
      assert person.full_name.surname == "Doe"
      assert person.email.value == "john.doe@example.com"
      assert person.date_of_birth.value == ~D[1990-01-01]

      assert %Events.PersonCreated{} = event
      assert event.id == "person_123"
      assert event.name == "John"
      assert event.surname == "Doe"
      assert event.email == "john.doe@example.com"
    end

    test "creation fails with invalid email" do
      command = %Commands.Create{
        id: "person_123",
        name: "John",
        surname: "Doe",
        email: "invalid-email",
        date_of_birth: ~D[1990-01-01]
      }

      assert {:error, error} = PersonAggregate.decide(nil, command)
      assert error.message =~ "Invalid email"
    end
  end

  describe "add address" do
    test "valid address" do
      createCmd = %Commands.Create{
        id: "person_123",
        name: "Alin",
        surname: "Ianitchii",
        email: "ciccio@yopmail.com",
        date_of_birth: ~D[1999-07-21]
      }

      addAddressCmd = %Commands.AddAddress{
        street: "Via Giulio Natta",
        number: "59",
        city: "Arcore",
        postal_code: "20862",
        state_or_province: "MB",
        country: "IT"
      }

      {:ok, createdPerson, _event} = PersonAggregate.evolve(nil, createCmd)

      assert {:ok, person, _event} = PersonAggregate.evolve(createdPerson, addAddressCmd)

      assert person.address == %AddressValueObject{
               street: "Via Giulio Natta",
               number: "59",
               city: "Arcore",
               postal_code: "20862",
               state_or_province: "MB",
               country: "IT"
             }
    end
  end

  describe "apply events" do
    test "apply PersonCreateed event" do
      event = %Events.PersonCreated{
        id: "person_123",
        name: "Sarah",
        surname: "Wilson",
        email: "sarah@example.com",
        date_of_birth: ~D[1985-05-15]
      }

      person = PersonAggregate.apply_event(nil, event)

      assert person.id == "person_123"
      assert person.full_name.name == "Sarah"
      assert person.full_name.surname == "Wilson"
      assert person.email.value == "sarah@example.com"
      assert person.date_of_birth.value == ~D[1985-05-15]
    end
  end
end
