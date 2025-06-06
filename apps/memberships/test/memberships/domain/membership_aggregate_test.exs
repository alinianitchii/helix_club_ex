defmodule Memberships.Domain.MembershipAggregateTest do
  use ExUnit.Case

  alias Memberships.Domain.PaymentStatusValueObject
  alias Memberships.Domain.MedicalCertificateStatusValueObject
  alias Memberships.Domain.Commands
  alias Memberships.Domain.Events
  alias Memberships.Domain.DurationValueObject
  alias Memberships.Domain.PriceValueObject
  alias Memberships.Domain.MembershipAggregate

  describe "create" do
    setup do
      command = %Commands.SubmitFreeApplication{
        id: "membership_123",
        person_id: "person_123",
        type: :yearly,
        start_date: ~D[2025-06-01]
      }

      {:ok, membership, event} = MembershipAggregate.evolve(nil, command)

      %{command: command, membership: membership, event: event}
    end

    test "assigns primitive fields from command", %{command: command, membership: membership} do
      assert membership.id == command.id
      assert membership.person_id == command.person_id
    end

    test "creates duration value object", %{membership: membership} do
      assert %DurationValueObject{} = membership.duration
    end

    test "creates medical certificate value object", %{membership: membership} do
      assert %MedicalCertificateStatusValueObject{} = membership.med_cert
    end

    test "emits FreeMembershipApplicationSubmitted event with correct fields", %{
      event: event,
      command: command
    } do
      assert %Events.FreeMembershipApplicationSubmitted{} = event

      assert event.id == command.id
      assert event.person_id == command.person_id
      assert event.type == command.type
      assert event.start_date == command.start_date
      assert %Date{} = event.end_date
      assert event.med_cert_status == :incomplete
    end
  end

  describe "create with price" do
    setup do
      command = %Commands.SubmitPaidApplication{
        id: "membership_123",
        person_id: "person_123",
        type: :yearly,
        start_date: ~D[2025-06-01],
        price: 100.00
      }

      {:ok, membership, event} = MembershipAggregate.evolve(nil, command)

      %{command: command, membership: membership, event: event}
    end

    test "creates price value object", %{membership: membership} do
      assert %PriceValueObject{} = membership.price
    end

    test "creates medical certificate value object", %{membership: membership} do
      assert %MedicalCertificateStatusValueObject{} = membership.med_cert
    end

    test "creates payment value object", %{membership: membership} do
      assert %PaymentStatusValueObject{} = membership.payment
    end

    test "emits PaidMembershipApplicationSubmitted event with correct fields", %{
      event: event,
      command: command
    } do
      assert %Events.PaidMembershipApplicationSubmitted{} = event

      assert event.id == command.id
      assert event.person_id == command.person_id
      assert event.type == command.type
      assert event.start_date == command.start_date
      assert %Date{} = event.end_date
      assert is_number(event.price)
      assert event.med_cert_status == :incomplete
      assert event.payment_status == :incomplete
    end
  end
end
