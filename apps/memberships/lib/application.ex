defmodule Memberships.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Memberships.Infrastructure.Db.Repo
      # {Phoenix.PubSub, [name: People.PubSub, pool_size: 1]},
      # People.EventSubscriber,
      # {Bandit, plug: People.Http.Router, scheme: :http, port: 4000}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Memberships.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
