defmodule MedicalCertificates.Domain.MedicalCertificateAggregate do
  alias MedicalCertificates.Domain.ValueObjects.ReqeustDate
  alias MedicalCertificates.Domain.ValueObjects.Validity
  alias People.Domain.FullNameValueObject
  alias MedicalCertificates.Domain.ValueObjects
  alias MedicalCertificates.Domain.MedicalCertificateAggregate

  defstruct [:id, :holder_id, :holder_full_name, :request_date, :validity]

  defmodule CreateRequest do
    defstruct [:id, :holder_id, :holder_name, :holder_surname]
  end

  defmodule MedicalCertificateRequested do
    defstruct [:id, :holder_id, :holder_name, :holder_surname, :request_date, :status]
  end

  defmodule Register do
    defstruct [:issue_date]
  end

  defmodule MedicalCertificateRegistered do
    defstruct [:id, :holder_id, :issue_date, :status]
  end

  def decide(nil, %CreateRequest{} = cmd) do
    with {:ok, holder_full_name} =
           FullNameValueObject.create(cmd.holder_name, cmd.holder_surname),
         {:ok, request_date} = ValueObjects.ReqeustDate.new(),
         {:ok, validity} = ValueObjects.Validity.new() do
      {:ok,
       %MedicalCertificateRequested{
         id: cmd.id,
         holder_id: cmd.holder_id,
         holder_name: holder_full_name.name,
         holder_surname: holder_full_name.surname,
         request_date: request_date.date,
         status: validity.status
       }}
    end
  end

  def decide(%MedicalCertificateAggregate{} = state, %Register{} = cmd) do
    with {:ok, validity} = ValueObjects.Validity.new(cmd.issue_date) do
      {:ok,
       %MedicalCertificateRegistered{
         id: state.id,
         holder_id: state.holder_id,
         issue_date: validity.issue_date,
         status: validity.status
       }}
    end
  end

  def apply_event(nil, %MedicalCertificateRequested{} = event) do
    %MedicalCertificateAggregate{
      id: event.id,
      holder_id: event.holder_id,
      holder_full_name: %FullNameValueObject{
        name: event.holder_name,
        surname: event.holder_surname
      },
      request_date: %ReqeustDate{date: event.request_date},
      validity: %Validity{issue_date: nil, status: event.status}
    }
  end

  def apply_event(%MedicalCertificateAggregate{} = state, %MedicalCertificateRegistered{} = event) do
    %MedicalCertificateAggregate{
      state
      | validity: %Validity{issue_date: event.issue_date, status: event.status}
    }
  end

  def evolve(state, command) do
    with {:ok, event} <- decide(state, command) do
      evolved_state = apply_event(state, event)
      {:ok, evolved_state, event}
    end
  end
end
