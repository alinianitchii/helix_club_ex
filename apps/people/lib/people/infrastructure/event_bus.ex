defmodule People.EventBus do
  def publish(event) do
    EventBus.publish({"person_domain_events", event})
  end
end
