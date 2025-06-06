defmodule Memberships.Domain.MembershipAggregate do
  alias Memberships.Domain.Commands.{SubmitFreeApplication, SubmitPaidApplication}

  alias Memberships.Domain.Events.{
    FreeMembershipApplicationSubmitted,
    PaidMembershipApplicationSubmitted
  }

  alias Memberships.Domain.DurationValueObject
  alias Memberships.Domain.PriceValueObject

  alias Memberships.Domain.MembershipAggregate

  defstruct [:id, :person_id, :duration, :membership_type_id, :price, :payment, :med_cert]

  def decide(nil, %SubmitFreeApplication{} = cmd) do
    with {:ok, duration} <- DurationValueObject.new(cmd.type, cmd.start_date) do
      {:ok,
       %FreeMembershipApplicationSubmitted{
         id: cmd.id,
         person_id: cmd.person_id,
         type: duration.type,
         membership_type_id: cmd.membership_type_id,
         start_date: duration.start_date,
         end_date: duration.end_date
       }}
    else
      {:error, %DomainError{} = error} -> {:error, error}
    end
  end

  def decide(nil, %SubmitPaidApplication{} = cmd) do
    with {:ok, duration} <- DurationValueObject.new(cmd.type, cmd.start_date),
         {:ok, price} <- PriceValueObject.new(cmd.price) do
      {:ok,
       %PaidMembershipApplicationSubmitted{
         id: cmd.id,
         person_id: cmd.person_id,
         type: duration.type,
         membership_type_id: cmd.membership_type_id,
         start_date: duration.start_date,
         end_date: duration.end_date,
         price: price.value
       }}
    else
      {:error, %DomainError{} = error} -> {:error, error}
    end
  end

  def apply_event(nil, %FreeMembershipApplicationSubmitted{} = event) do
    %FreeMembershipApplicationSubmitted{
      id: id,
      person_id: person_id,
      type: type,
      membership_type_id: membership_type_id,
      start_date: start_date,
      end_date: end_date
    } = event

    %MembershipAggregate{
      id: id,
      person_id: person_id,
      duration: %DurationValueObject{type: type, start_date: start_date, end_date: end_date},
      membership_type_id: membership_type_id,
      payment: nil,
      med_cert: nil
    }
  end

  def apply_event(nil, %PaidMembershipApplicationSubmitted{} = event) do
    %PaidMembershipApplicationSubmitted{
      id: id,
      person_id: person_id,
      type: type,
      membership_type_id: membership_type_id,
      start_date: start_date,
      end_date: end_date,
      price: price
    } = event

    %MembershipAggregate{
      id: id,
      person_id: person_id,
      duration: %DurationValueObject{type: type, start_date: start_date, end_date: end_date},
      membership_type_id: membership_type_id,
      price: %PriceValueObject{value: price},
      payment: nil,
      med_cert: nil
    }
  end

  def evolve(state, command) do
    with {:ok, event} <- decide(state, command) do
      new_state = apply_event(state, event)
      {:ok, new_state, event}
    end
  end
end
