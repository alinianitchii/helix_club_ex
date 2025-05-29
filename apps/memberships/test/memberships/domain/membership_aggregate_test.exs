defmodule Memberships.Domain.MembershipAggregateTest do
  use ExUnit.Case

  alias Memberships.Domain.Commands
  alias Memberships.Domain.Events
  alias Memberships.Domain.DurationValueObject
  alias Memberships.Domain.MembershipAggregate

  describe "create/1" do
    setup do
      command = %Commands.Create{
        id: "membership_123",
        person_id: "person_123",
        type: :annual,
        start_date: ~D[2025-06-01]
      }

      {:ok, membership, event} = MembershipAggregate.evolve(nil, command)

      %{command: command, membership: membership, event: event}
    end

    test "assigns primitive fields from command", %{command: command, membership: membership} do
      assert membership.id == command.id
      assert membership.person_id == command.person_id
    end

    test "creates correct duration value object", %{membership: membership, command: command} do
      assert membership.duration == %DurationValueObject{
               type: command.type,
               start_date: command.start_date,
               end_date: ~D[2026-05-31]
             }
    end

    test "emits MembershipCreated event with correct fields", %{event: event, command: command} do
      assert %Events.MembershipCreated{} = event

      assert event.id == command.id
      assert event.person_id == command.person_id
      assert event.type == command.type
      assert event.start_date == command.start_date
      assert event.end_date == ~D[2026-05-31]
    end
  end
end
