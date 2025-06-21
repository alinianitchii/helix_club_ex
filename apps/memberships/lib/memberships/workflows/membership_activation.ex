defmodule Memberships.Workflows.MembershipActication do
  alias Memberships.Domain.Events.FreeMembershipApplicationSubmitted
  alias Memberships.Workflows.Scheduler.TryActivateMembership
  alias Memberships.Infrastructure.Repositories.MembershipActivationWorkflow

  def handle(%FreeMembershipApplicationSubmitted{
        id: membership_id,
        person_id: person_id,
        start_date: start_date
      }) do
    process_state = %{process_id: membership_id, person_id: person_id, status: :in_progress}
    MembershipActivationWorkflow.upsert(process_state)

    TryActivateMembership.schedule(membership_id, start_date)

    {:ok, process_state}
  end
end
