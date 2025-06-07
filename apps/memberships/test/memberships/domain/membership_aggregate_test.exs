defmodule Memberships.Domain.MembershipAggregateTest do
  use ExUnit.Case

  alias Memberships.Domain.StatusValueObject
  alias Memberships.Domain.PaymentStatusValueObject
  alias Memberships.Domain.MedicalCertificateStatusValueObject
  alias Memberships.Domain.Commands
  alias Memberships.Domain.Events
  alias Memberships.Domain.DurationValueObject
  alias Memberships.Domain.PriceValueObject
  alias Memberships.Domain.MembershipAggregate

  defp create_free_membership do
    command = %Commands.SubmitFreeApplication{
      id: "membership_123",
      person_id: "person_123",
      type: :yearly,
      start_date: ~D[2025-06-01]
    }

    {:ok, membership, event} = MembershipAggregate.evolve(nil, command)

    %{command: command, membership: membership, event: event}
  end

  defp create_paid_membership do
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

  describe "create" do
    setup do
      create_free_membership()
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

    test "creates status value object", %{membership: membership} do
      assert %StatusValueObject{} = membership.status
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
      create_paid_membership()
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

    test "creates status value object", %{membership: membership} do
      assert %StatusValueObject{} = membership.status
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

  describe "activate free membership" do
    setup do
      create_free_membership()
    end

    test "medical certificate status still incomplete", %{membership: membership} do
      command = %Commands.Activate{}

      {:error, reason} = MembershipAggregate.evolve(membership, command)

      assert reason == DomainError.new(:invalid_state, "Invalid medical certificate")
    end
  end

  describe "activate paid membership" do
    setup do
      create_paid_membership()
    end

    test "medical certificate is not valid", %{membership: membership} do
      command = %Commands.Activate{}

      {:error, reason} = MembershipAggregate.evolve(membership, command)

      assert reason == DomainError.new(:invalid_state, "Invalid medical certificate")
    end

    test "payment status is not paid", %{membership: membership} do
      change_medical_status_cmd = %Commands.ChangeMedicalCertificateStatus{status: :valid}
      {:ok, membership, _} = MembershipAggregate.evolve(membership, change_medical_status_cmd)

      activate_cmd = %Commands.Activate{}
      {:error, reason} = MembershipAggregate.evolve(membership, activate_cmd)

      assert reason == DomainError.new(:invalid_state, "Invalid payment status")
    end

    test "medical certificate is valid and payment status is paid", %{membership: membership} do
      change_medical_status_cmd = %Commands.ChangeMedicalCertificateStatus{status: :valid}
      {:ok, membership, _} = MembershipAggregate.evolve(membership, change_medical_status_cmd)

      change_payment_status_cmd = %Commands.ChangePaymentStatus{status: :paid}
      {:ok, membership, _} = MembershipAggregate.evolve(membership, change_payment_status_cmd)

      activate_cmd = %Commands.Activate{}
      {:ok, membership, _} = MembershipAggregate.evolve(membership, activate_cmd)

      assert membership.status.status == :activated
    end
  end
end
