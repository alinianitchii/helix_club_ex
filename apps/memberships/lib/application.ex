defmodule Memberships.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Memberships.Infrastructure.Db.Repo,
      {Bandit, plug: Memberships.Http.Router, scheme: :http, port: 4001},
      Memberships.Infrastructure.MembershipEventSubscriber,
      Memberships.Workflows.MembershipEventsSubscriber,
      Memberships.Integration.CommandHandlers.MedicalCertificateStatusChanged,
      Memberships.Integration.CommandHandlers.PaymentStatusChanged,
      {Oban, Keyword.put(Application.fetch_env!(:memberships, Oban), :name, Memberships.Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Memberships.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
