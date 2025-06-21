defmodule Payments.Infrastructure.IntegrationCommandHandlers do
  use GenServer
  require Logger

  alias Payments.IntegrationCommands.CreatePayment
  alias Payments.Application.Commands.Create

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    PubSub.CommandBus.subscribe("commands")
    {:ok, %{}}
  end

  def handle_info(%CreatePayment{} = cmd, state) do
    try do
      Create.execute(cmd)
      {:noreply, state}
    rescue
      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end
end
