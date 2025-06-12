defmodule People.Application.Query.GetPersonById do
  alias People.Infrastructure.Repository.PeopleReadRepo

  def execute(id) do
    case PeopleReadRepo.get_person(id) do
      nil -> {:error, :not_found}
      person -> {:ok, person}
    end
  end
end
