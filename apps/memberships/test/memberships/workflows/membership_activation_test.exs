defmodule Memberships.Workflows.MembershipActicationTest do
  use Memberships.DataCase

  alias Memberships.Domain.Events.FreeMembershipApplicationSubmitted
  alias Memberships.Workflows.MembershipActication
  alias Memberships.Infrastructure.Repositories.MembershipActivationWorkflow

  describe "on application submitted" do
    test "process state initiation" do
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

      {:ok, state} = MembershipActication.handle(event)

      assert state.process_id == event.id
      assert state.person_id == event.person_id
      assert state.status == :in_progress
    end

    test "persist process state initiation" do
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

      {:ok, state} = MembershipActication.handle(event)

      saved_state = MembershipActivationWorkflow.get_by_id(state.process_id)

      assert saved_state != nil
    end

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

      {:ok, _} = MembershipActication.handle(event)

      assert_enqueued(
        worker: Memberships.Workflows.Jobs.TryActivateMembership,
        args: %{id: event.id}
      )
    end
  end
end
