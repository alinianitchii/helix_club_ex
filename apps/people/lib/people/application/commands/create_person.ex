defmodule People.Application.Command.CreatePerson do
  alias People.Domain.Commands.Create
  alias People.Domain.PersonAggregate
  alias People.Infrastructure.Repository.PeopleWriteRepo

  def execute(%{
        "id" => id,
        "name" => name,
        "surname" => surname,
        "email" => email,
        "date_of_birth" => dob
      }) do
    {:ok, parsed_dob} = Date.from_iso8601(dob)

    command = %Create{
      id: id,
      name: name,
      surname: surname,
      email: email,
      date_of_birth: parsed_dob
    }

    with {:ok, person, event} <- PersonAggregate.evolve(nil, command),
         {:ok, _} <- PeopleWriteRepo.save_and_publish(person, [event]) do
      {:ok, person.id}
    end
  end
end
