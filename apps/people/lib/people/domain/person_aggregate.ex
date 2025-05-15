defmodule People.Domain.PersonAggregate do


  alias People.Domain.PersonAggregate.Events.PersonCreated
  alias People.Domain.PersonAggregate
  alias People.Domain.FullNameValueObject
  alias People.Domain.EmailValueObject
  alias People.Domain.BirthDateValueObject
  alias People.Domain.AddressValueObject

  alias People.Domain.Commands.Create
  alias People.Domain.Commands.AddAddress
  alias People.Domain.Events.PersonCreated
  alias People.Domain.Events.PersonAddressChanged


  defstruct [
    :id,
    :full_name,
    :email,
    :address,
    :date_of_birth
  ]

  def decide(nil, %Create{} = cmd) do
    with {:ok, full_name} <- FullNameValueObject.create(cmd.name, cmd.surname),
         {:ok, email} <- EmailValueObject.new(cmd.email),
         {:ok, date_of_birth} <- BirthDateValueObject.new(cmd.date_of_birth) do
      {:ok,
       %PersonCreated{
         id: cmd.id,
         name: full_name.name,
         surname: full_name.surname,
         email: email.value,
         date_of_birth: date_of_birth.value
       }}
    else
      {:error, %DomainError{} = error} -> {:error, error}
    end
  end

  def decide(%PersonAggregate{} = person, %AddAddress{} = cmd) do
   with {:ok, address} <-
          AddressValueObject.new(
            cmd.street,
            cmd.number,
            cmd.city,
            cmd.postal_code,
            cmd.state_or_province,
            cmd.country
          ) do
     {:ok,
      %PersonAddressChanged{
        id: person.id,
        street: address.street,
        number: address.number,
        city: address.city,
        postal_code: address.postal_code,
        state_or_province: address.state_or_province,
        country: address.country
      }}
   else
     {:error, %DomainError{} = error} -> {:error, error}
   end
  end

  def apply_event(nil, %PersonCreated{} = event) do
    %PersonCreated{
      id: id,
      name: name,
      surname: surname,
      email: email,
      date_of_birth: date_of_birth
    } = event

    %PersonAggregate{
         id: id,
        full_name: %FullNameValueObject{name: name, surname: surname},
        email: %EmailValueObject{value: email},
        date_of_birth: %BirthDateValueObject{value: date_of_birth}
    }
  end

   def apply_event(%PersonAggregate{} = person, %PersonAddressChanged{} = evt) do
    %PersonAggregate{
      person
      | address: %AddressValueObject{
          street: evt.street,
          number: evt.number,
          city: evt.city,
          postal_code: evt.postal_code,
          state_or_province: evt.state_or_province,
          country: evt.country
        }
    }
   end


   def evolve(state, command) do
    with {:ok, event} <- decide(state, command) do
      new_state = apply_event(state, event)
      {:ok, new_state, event}
    end
   end
end
