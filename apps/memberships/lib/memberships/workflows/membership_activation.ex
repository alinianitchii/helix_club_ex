defmodule Memberships.Workflows.MembershipActication do
  alias Memberships.Domain.Events.{
    FreeMembershipApplicationSubmitted,
    PaidMembershipApplicationSubmitted
  }

  alias Memberships.Workflows.Scheduler.TryActivateMembership
  alias Memberships.Infrastructure.Repositories.MembershipActivationWorkflow
  alias Memberships.Infrastructure.Db.Repo

  def handle(%FreeMembershipApplicationSubmitted{
        id: membership_id,
        person_id: person_id,
        start_date: start_date
      }) do
    process_state = %{process_id: membership_id, person_id: person_id, status: :in_progress}

    Repo.transaction(fn ->
      MembershipActivationWorkflow.upsert(process_state)
      TryActivateMembership.schedule(membership_id, start_date)
    end)

    # TODO publish request medical certification command

    {:ok, process_state}
  end

  def handle(%PaidMembershipApplicationSubmitted{
        id: membership_id,
        person_id: person_id,
        start_date: start_date
      }) do
    process_state = %{process_id: membership_id, person_id: person_id, status: :in_progress}

    Repo.transaction(fn ->
      MembershipActivationWorkflow.upsert(process_state)
      TryActivateMembership.schedule(membership_id, start_date)
    end)

    # TODO publish request medical certification command

    {:ok, process_state}
  end
end
