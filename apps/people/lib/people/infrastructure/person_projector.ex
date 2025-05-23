defmodule People.EventSubscriber do
  use GenServer
  require Logger

  alias People.Projectors.PersonProjector

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    Phoenix.PubSub.subscribe(People.PubSub, "person_domain_events")
    {:ok, %{}}
  end

  def handle_info(event, state) do
    try do
      PersonProjector.handle(event)
      {:noreply, state}
    rescue
      e in DBConnection.ConnectionError ->
        Logger.error("Database connection error: #{inspect(e)}")
        {:noreply, state}

      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end
end

defmodule People.Projectors.PersonProjector do
  alias People.Infrastructure.Repository.PersonReadRepo
  alias People.Domain.Events.PersonCreated
  alias People.Domain.Events.PersonAddressChanged

  def handle(%PersonCreated{} = event) do
    PersonReadRepo.upsert_person(%{
      id: event.id,
      name: event.name,
      surname: event.surname,
      email: event.email,
      date_of_birth: event.date_of_birth
    })
  end

  def handle(%PersonAddressChanged{} = event) do
    case PersonReadRepo.get_person(event.id) do
      {:ok, existing_person} ->
        # Update the address field as a nested map
        updated_person =
          Map.put(existing_person, :address, %{
            street: event.street,
            number: event.number,
            city: event.city,
            postal_code: event.postal_code,
            state_or_province: event.state_or_province,
            country: event.country
          })

          PersonReadRepo.upsert_person(updated_person)

      error ->
        error
    end
  end
end
