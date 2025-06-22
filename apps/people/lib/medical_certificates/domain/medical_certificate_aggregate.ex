defmodule MedicalCertificates.Domain.MedicalCertificateAggregate do
  alias MedicalCertificates.Domain.ValueObjects.Validity
  alias People.Domain.FullNameValueObject
  alias MedicalCertificates.Domain.ValueObjects
  alias MedicalCertificates.Domain.MedicalCertificateAggregate

  defstruct [:id, :holder_full_name, :validity]

  defmodule Register do
    defstruct [:id, :holder_id, :holder_name, :holder_surname, :issue_date]
  end

  defmodule MedicalCertificateRegistered do
    defstruct [:id, :holder_id, :holder_name, :holder_surname, :issue_date, :status]
  end

  def decide(nil, %Register{} = cmd) do
    with {:ok, holder_full_name} =
           FullNameValueObject.create(cmd.holder_name, cmd.holder_surname),
         {:ok, validity} = ValueObjects.Validity.new(cmd.issue_date) do
      {:ok,
       %MedicalCertificateRegistered{
         id: cmd.id,
         holder_id: cmd.holder_id,
         holder_name: holder_full_name.name,
         holder_surname: holder_full_name.surname,
         issue_date: validity.issue_date,
         status: validity.status
       }}
    end
  end

  def apply_event(nil, %MedicalCertificateRegistered{} = event) do
    %MedicalCertificateAggregate{
      id: event.id,
      holder_full_name: %FullNameValueObject{
        name: event.holder_name,
        surname: event.holder_surname
      },
      validity: %Validity{issue_date: event.issue_date, status: event.status}
    }
  end

  def evolve(state, command) do
    case decide(state, command) do
      {:ok, nil} ->
        {:ok, state, nil}

      {:ok, event} ->
        new_state = apply_event(state, event)
        {:ok, new_state, event}
    end
  end
end
