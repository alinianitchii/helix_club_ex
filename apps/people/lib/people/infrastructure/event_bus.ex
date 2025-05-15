defmodule People.EventBus do
  def publish(event) do
    Phoenix.PubSub.broadcast(People.PubSub, "person_domain_events", event)
  end
end
