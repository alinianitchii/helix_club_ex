defmodule Memberships.EventBus do
  def publish(event) do
    EventBus.publish({"membership_domain_events", event})
  end
end
