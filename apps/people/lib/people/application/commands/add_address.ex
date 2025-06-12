defmodule People.Application.Command.AddAddress do
  alias People.Domain.Commands.AddAddress
  alias People.Domain.PersonAggregate
  alias People.Infrastructure.Repository.PeopleWriteRepo

  def execute(%{
        "id" => id,
        "street" => street,
        "number" => number,
        "city" => city,
        "postal_code" => postal_code,
        "state_or_province" => state_or_province,
        "country" => country
      }) do
    command = %AddAddress{
      street: street,
      number: number,
      city: city,
      postal_code: postal_code,
      state_or_province: state_or_province,
      country: country
    }

    case PeopleWriteRepo.get(id) do
      {:error, :not_found} ->
        {:error, :not_found}

      {:ok, person} ->
        with {:ok, person, event} <- PersonAggregate.evolve(person, command),
             {:ok, _} <- PeopleWriteRepo.save_and_publish(person, [event]) do
          {:ok}
        end
    end
  end
end
