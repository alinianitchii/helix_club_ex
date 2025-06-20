defmodule Memberships.Workflows.MembershipActication do
  alias Memberships.Domain.Events.FreeMembershipApplicationSubmitted
  alias Memberships.Workflows.Scheduler.TryActivateMembership

  def handle(%FreeMembershipApplicationSubmitted{id: membership_id, start_date: start_date}) do
    TryActivateMembership.schedule(membership_id, start_date)

    {:ok}
  end
end
