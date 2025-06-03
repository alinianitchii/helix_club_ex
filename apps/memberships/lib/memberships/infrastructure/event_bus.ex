defmodule Memberships.EventBus do
  def publish(event) do
    Phoenix.PubSub.broadcast(Memberships.PubSub, "membership_domain_events", event)
  end
end
