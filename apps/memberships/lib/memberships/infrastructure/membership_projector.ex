defmodule Memberships.Infrastructure.MembershipEventSubscriber do
  use GenServer
  require Logger

  alias Memberships.Infrastructure.Projectors.MembershipProjector

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    Memberships.EventBus.subscribe("membership_domain_events")
    {:ok, %{}}
  end

  def handle_info(event, state) do
    try do
      MembershipProjector.handle(event)
      {:noreply, state}
    rescue
      e in DBConnection.ConnectionError ->
        Logger.error("Database connection error: #{inspect(e)}")
        {:noreply, state}

      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end
end

defmodule Memberships.Infrastructure.Projectors.MembershipProjector do
  alias Memberships.Infrastructure.Repositories.MembershipReadRepo

  alias Memberships.Domain.Events.{
    FreeMembershipApplicationSubmitted,
    PaidMembershipApplicationSubmitted
  }

  def handle(%FreeMembershipApplicationSubmitted{} = event) do
    MembershipReadRepo.upsert(%{
      id: event.id,
      person_id: event.person_id,
      type: Atom.to_string(event.type),
      membership_type_id: event.membership_type_id,
      start_date: event.start_date,
      end_date: event.end_date
    })
  end

  def handle(%PaidMembershipApplicationSubmitted{} = event) do
    MembershipReadRepo.upsert(%{
      id: event.id,
      person_id: event.person_id,
      type: Atom.to_string(event.type),
      membership_type_id: event.membership_type_id,
      start_date: event.start_date,
      end_date: event.end_date,
      price: event.price
    })
  end
end
