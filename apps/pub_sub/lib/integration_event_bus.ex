defmodule PubSub.Integration.EventBus do
  def publish(event) do
    PubSub.publish({"integration.events", event})
  end

  def subscribe(topic) do
    PubSub.subscribe(topic)
  end
end
