defmodule Memberships.Integration.CommandHandlers.MedicalCertificateStatusChanged do
  use GenServer
  require Logger

  alias Memberships.Infrastructure.Repositories.MembershipReadRepo
  alias Memberships.Application.Commands

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    PubSub.Integration.EventBus.subscribe("integration.events")
    {:ok, %{}}
  end

  def handle_info(
        %{type: :event, name: "medical-certificate.status-changed", paylaod: payload},
        state
      ) do
    try do
      memberships = MembershipReadRepo.get_by_person_id(payload.holder_id)

      Enum.each(memberships, fn membership ->
        :ok =
          Commands.ChangeMedicalCertificateStatus.execute(%{
            "id" => membership.id,
            "med_cert_new_status" => payload.status
          })
      end)

      {:noreply, state}
    rescue
      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end

  def handle_info(event, state) do
    Logger.debug(
      "Unhandled event: #{inspect(event)}. Memberships.Integration.CommandHandlers.MedicalCertificateStatusChanged"
    )

    {:noreply, state}
  end
end
