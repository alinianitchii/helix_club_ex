defmodule Payments.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Payments.Infrastructure.Db.Repo,
      {Bandit, plug: Payments.Http.Router, scheme: :http, port: 4002},
      Payments.Infrastructure.PaymentsEventSubscriber
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Payments.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
