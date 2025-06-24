defmodule Memberships.Integration.MedicalCertificateStatusChangedTest do
  use Memberships.DataCase

  alias Memberships.Infrastructure.Repositories.MembershipReadRepo

  @person_id UUID.uuid4()
  @new_status "valid"

  setup do
    {:ok, mt} =
      Memberships.MembershipTypes.create_membership_type(%{
        "name" => "Annual Membership 2025",
        "type" => "yearly",
        "description" => ""
      })

    create_membership_fixture = %{
      "id" => UUID.uuid4(),
      "person_id" => @person_id,
      "start_date" => "2025-06-24",
      "membership_type_id" => mt.id
    }

    :ok = Memberships.Application.Command.SubmitApplication.execute(create_membership_fixture)
    Process.sleep(100)

    {:ok, membership_id: create_membership_fixture["id"]}
  end

  test "updates membership medical certificate status on integration event", %{membership_id: id} do
    # Simulate incoming event
    PubSub.Integration.EventBus.publish(%{
      type: :event,
      name: "medical-certificate.status-changed",
      paylaod: %{
        holder_id: @person_id,
        status: @new_status
      }
    })

    # Give time for async processing
    Process.sleep(100)

    updated = MembershipReadRepo.get_by_id(id)

    assert updated.med_cert_status == String.to_atom(@new_status)
  end
end
