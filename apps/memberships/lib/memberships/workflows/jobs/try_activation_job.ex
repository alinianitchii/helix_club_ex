defmodule Memberships.Workflows.Jobs.TryActivateMembership do
  use Oban.Worker, queue: :membership_activation

  alias Memberships.Application.Command

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Command.Activate.execute(%{"id" => id})
  end
end
