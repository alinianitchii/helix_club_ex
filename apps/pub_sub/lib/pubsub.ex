defmodule PubSub do
  @moduledoc """
  Simple wrapper around `Phoenix.PubSub` used across the umbrella.
  """

  def publish({topic, message}) do
    Phoenix.PubSub.broadcast(Helix.PubSub, topic, message)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Helix.PubSub, topic)
  end
end
