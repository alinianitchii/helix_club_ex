defmodule PubSub.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Helix.PubSub, pool_size: 1}
    ]

    opts = [strategy: :one_for_one, name: EventBus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
