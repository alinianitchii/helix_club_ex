defmodule Memberships.Workflows.MembershipActicationTest do
  use Memberships.DataCase

  alias Memberships.Domain.Events.FreeMembershipApplicationSubmitted
  alias Memberships.Workflows.MembershipActication

  describe "on application submitted" do
    test "schedule activation job" do
      start_date = Date.add(Date.utc_today(), 10)
      end_date = Date.add(start_date, 30)

      event = %FreeMembershipApplicationSubmitted{
        id: UUID.uuid4(),
        person_id: UUID.uuid4(),
        type: :monthly,
        membership_type_id: UUID.uuid4(),
        start_date: start_date,
        end_date: end_date,
        med_cert_status: :incomplete,
        status: :pending
      }

      {:ok} = MembershipActication.handle(event)

      assert_enqueued(
        worker: Memberships.Workflows.Jobs.TryActivateMembership,
        args: %{id: event.id}
      )
    end
  end
end
