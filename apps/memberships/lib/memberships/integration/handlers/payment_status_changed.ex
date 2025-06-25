defmodule Memberships.Integration.CommandHandlers.PaymentStatusChanged do
  use GenServer
  require Logger

  alias Memberships.Application.Commands

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    PubSub.Integration.EventBus.subscribe("integration.events")
    {:ok, %{}}
  end

  def handle_info(%{type: :event, name: "payment.status-changed", paylaod: payload}, state) do
    try do
      :ok =
        Commands.ChangePaymentStatus.execute(%{
          "id" => payload.product_id,
          "payment_new_status" => payload.status
        })

      {:noreply, state}
    rescue
      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end

  def handle_info(event, state) do
    Logger.debug(
      "Unhandled event: #{inspect(event)}. Memberships.Integration.CommandHandlers.PaymentStatusChanged"
    )

    {:noreply, state}
  end
end
