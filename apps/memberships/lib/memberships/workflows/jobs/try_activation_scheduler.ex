defmodule Memberships.Workflows.Scheduler.TryActivateMembership do
  alias Memberships.Workflows.Jobs.TryActivateMembership

  def schedule(membership_id, start_date) do
    TryActivateMembership.new(
      %{id: membership_id},
      queue: "membership_activation",
      scheduled_at: DateTime.new!(start_date, Time.utc_now())
    )
    |> Oban.insert()
  end
end
