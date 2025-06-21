defmodule PubSub.CommandBus do
  def publish(command) do
    PubSub.publish({"commands", command})
  end

  def subscribe(topic) do
    PubSub.subscribe(topic)
  end
end
