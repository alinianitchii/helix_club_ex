defmodule People.Application.Query.GetPersonById do
  alias People.Infrastructure.Repository.PersonReadRepo

  def execute(id) do
    case PersonReadRepo.get_person(id) do
      nil -> {:error, :not_found}
      person -> {:ok, person}
    end
  end
end
