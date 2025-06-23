defmodule Payments.Infrastructure.IntegrationCommandHandlers do
  use GenServer
  require Logger

  alias Payments.Integration.Commands.CreatePayment
  alias Payments.Application.Commands.Create

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    PubSub.Integration.CommandBus.subscribe("integration_commands")
    {:ok, %{}}
  end

  # TODO: find out if this is a viable solution to handle only specific commands
  def handle_info(%{type: :command, name: "payment.create", paylaod: payload}, state) do
    try do
      cmd = CreatePayment.new(payload)

      Create.execute(cmd)
      {:noreply, state}
    rescue
      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end
end
