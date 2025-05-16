defmodule People.OutboxPublisher do
  use GenServer
  import Ecto.Query
  alias People.Infrastructure.Db.Repo
  alias People.Infrastructure.Db.Schema.OutboxSchema
  alias People.EventBus

  @interval 1_000

  def start_link(_args), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    publish_pending_events()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @interval)
  end

  defp publish_pending_events do
    events =
      OutboxSchema
      |> where([e], is_nil(e.published_at))  # or some `status == "pending"` if you prefer
      |> limit(10)
      |> Repo.all() |> IO.inspect()

    for event <- events do
      case publish_event(event) do
        :ok ->
          Repo.update!(Ecto.Changeset.change(event, published_at: DateTime.utc_now() |> DateTime.truncate(:second)))
        :error ->
          # log or retry later
          :noop
      end
    end
  end

  defp publish_event(event) do
    domain_event = deserialize_event(event.event_type, event.payload)

    try do
      EventBus.publish(domain_event)
      :ok
    rescue
      _ -> :error
    end
  end

  defp deserialize_event("person_created", payload) do
    %People.Domain.Events.PersonCreated{
      id: payload["id"],
      name: payload["name"],
      surname: payload["surname"],
      email: payload["email"],
      date_of_birth: Date.from_iso8601!(payload["date_of_birth"])
    }
  end

  defp deserialize_event("person_address_changed", payload) do
    %People.Domain.Events.PersonAddressChanged{
      id: payload["id"],
      street: payload["street"],
      number: payload["number"],
      city: payload["city"],
      postal_code: payload["postal_code"],
      state_or_province: payload["state_or_province"],
      country: payload["country"]
    }
  end
end
