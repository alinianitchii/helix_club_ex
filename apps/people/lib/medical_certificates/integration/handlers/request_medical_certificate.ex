defmodule MedicalCertificates.Integration.CommandHandlers.RequestMedicalCertificate do
  use GenServer
  require Logger

  alias MedicalCertificates.Integration.Commands.RequestMedicalCertificate
  alias MedicalCertificates.Application.Commands
  alias MedicalCertificates.Application.Queries

  def start_link(_), do: GenServer.start_link(__MODULE__, %{})

  def init(_) do
    PubSub.Integration.CommandBus.subscribe("integration_commands")
    {:ok, %{}}
  end

  # TODO: find out if this is a viable solution to handle only specific commands
  def handle_info(%{type: :command, name: "medical-certificate.request", paylaod: payload}, state) do
    try do
      cmd = RequestMedicalCertificate.new(payload)

      holder_certificates = Queries.GetByHolderId.execute(cmd.holder_id)
      valid_certificate = holder_certificates |> Enum.find(fn mc -> mc.status == :valid end)

      case valid_certificate != nil do
        true ->
          {:ok, person} = People.Application.Query.GetPersonById.execute(cmd.holder_id)

          Commands.CreateRequest.execute(%{
            "id" => UUID.uuid4(),
            "holder_id" => cmd.holder_id,
            "holder_name" => person.name,
            "holder_surname" => person.surname
          })

        false ->
          # TODO find out how to standardize the form
          MedicalCertificates.EventBus.publish(%{
            type: :event,
            name: "medical-certificate.status-changed",
            payload: %{id: valid_certificate.id, holder_id: cmd.holder_id, status: :valid}
          })
      end

      {:noreply, state}
    rescue
      e ->
        Logger.error("Error processing event: #{inspect(e)}")
        {:noreply, state}
    end
  end
end
