defmodule Payments.Workers.Payments.PaymentsEventSubscriber do
  use GenServer
  require Logger

  alias Payments.Workers.Payments.PaymentDueDateScheduler

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    Payments.EventBus.subscribe("payments_domain_events")
    {:ok, %{}}
  end

  def handle_info(event, state) do
    try do
      PaymentDueDateScheduler.handle(event)
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
