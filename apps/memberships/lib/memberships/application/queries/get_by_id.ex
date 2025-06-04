defmodule Memberships.Application.Query.GetMembershipById do
  alias Memberships.Infrastructure.Repositories.MembershipReadRepo

  def execute(id) do
    case MembershipReadRepo.get_by_id(id) do
      nil -> {:error, :not_found}
      memeberhsip -> {:ok, memeberhsip}
    end
  end
end
