defmodule Payments.EventBus do
  def publish(event) do
    PubSub.publish({"payments_domain_events", event})
  end

  def subscribe(topic) do
    PubSub.subscribe(topic)
  end
end
