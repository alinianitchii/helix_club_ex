defmodule Memberships.Integration.CommandHandlers.PaymentStatusChanged do
  use GenServer
  require Logger

  alias Memberships.Application.Commands

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    PubSub.Integration.EventBus.subscribe("integration_events")
    {:ok, %{}}
  end

  def handle_info(%{type: :event, name: "payment.status-changed", paylaod: payload}, state) do
    try do
      Commands.ChangePaymentStatus.execute(%{
        id: payload.product_id,
        payment_new_status: payload.status
      })

      {:noreply, state}
    rescue
      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end
end
