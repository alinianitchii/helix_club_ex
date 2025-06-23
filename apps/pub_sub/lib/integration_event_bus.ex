defmodule PubSub.Integration.EventBus do
  def publish(command) do
    PubSub.publish({"integration.events", command})
  end

  def subscribe(topic) do
    PubSub.subscribe(topic)
  end
end
