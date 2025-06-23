defmodule PubSub.Integration.CommandBus do
  def publish(command) do
    PubSub.publish({"integration.commands", command})
  end

  def subscribe(topic) do
    PubSub.subscribe(topic)
  end
end
