defmodule Memberships.Integration.PaymentStatusChangeddTest do
  use Memberships.DataCase

  alias Memberships.Infrastructure.Repositories.MembershipReadRepo

  @new_status "pending"

  setup do
    {:ok, mt} =
      Memberships.MembershipTypes.create_membership_type(%{
        "name" => "Annual Membership 2025",
        "type" => "yearly",
        "price" => 10
      })

    create_membership_fixture = %{
      "id" => UUID.uuid4(),
      "person_id" => UUID.uuid4(),
      "start_date" => "2025-06-24",
      "membership_type_id" => mt.id
    }

    :ok = Memberships.Application.Command.SubmitApplication.execute(create_membership_fixture)
    Process.sleep(100)

    {:ok, membership_id: create_membership_fixture["id"]}
  end

  test "updates membership payment status on integration event", %{membership_id: id} do
    # Simulate incoming event
    PubSub.Integration.EventBus.publish(%{
      type: :event,
      name: "payment.status-changed",
      paylaod: %{
        payment_id: UUID.uuid4(),
        product_id: id,
        status: @new_status,
        previous_status: nil
      }
    })

    # Give time for async processing
    Process.sleep(100)

    updated = MembershipReadRepo.get_by_id(id)

    assert updated.payment_status == String.to_atom(@new_status)
  end
end
