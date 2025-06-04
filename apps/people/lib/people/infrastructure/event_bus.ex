defmodule People.EventBus do
  def publish(event) do
    PubSub.publish({"person_domain_events", event})
  end

  def subscribe(topic) do
    PubSub.subscribe(topic)
  end
end
