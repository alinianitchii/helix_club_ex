defmodule Memberships.Domain.MembershipAggregate do
  alias Memberships.Domain.Commands.ChangePaymentStatus
  alias Memberships.Domain.StatusValueObject
  alias Memberships.Domain.PaymentStatusValueObject
  alias Memberships.Domain.MedicalCertificateStatusValueObject

  alias Memberships.Domain.Commands.{
    SubmitFreeApplication,
    SubmitPaidApplication,
    Activate,
    ChangeMedicalCertificateStatus
  }

  alias Memberships.Domain.Events.{
    FreeMembershipApplicationSubmitted,
    PaidMembershipApplicationSubmitted,
    MembershipMedicalCertificationStatusChanged,
    MembershipPaymentStatusChanged,
    MembershipActivated
  }

  alias Memberships.Domain.DurationValueObject
  alias Memberships.Domain.PriceValueObject

  alias Memberships.Domain.MembershipAggregate

  defstruct [
    :id,
    :person_id,
    :duration,
    :membership_type_id,
    :price,
    :payment,
    :med_cert,
    :status
  ]

  def decide(nil, %SubmitFreeApplication{} = cmd) do
    with {:ok, duration} <- DurationValueObject.new(cmd.type, cmd.start_date),
         {:ok, med_cert} <- MedicalCertificateStatusValueObject.new(),
         {:ok, status} <- StatusValueObject.new() do
      {:ok,
       %FreeMembershipApplicationSubmitted{
         id: cmd.id,
         person_id: cmd.person_id,
         type: duration.type,
         membership_type_id: cmd.membership_type_id,
         start_date: duration.start_date,
         end_date: duration.end_date,
         med_cert_status: med_cert.status,
         status: status.status
       }}
    end
  end

  def decide(nil, %SubmitPaidApplication{} = cmd) do
    with {:ok, duration} <- DurationValueObject.new(cmd.type, cmd.start_date),
         {:ok, price} <- PriceValueObject.new(cmd.price),
         {:ok, med_cert} <- MedicalCertificateStatusValueObject.new(),
         {:ok, payment} <- PaymentStatusValueObject.new(),
         {:ok, status} <- StatusValueObject.new() do
      {:ok,
       %PaidMembershipApplicationSubmitted{
         id: cmd.id,
         person_id: cmd.person_id,
         type: duration.type,
         membership_type_id: cmd.membership_type_id,
         start_date: duration.start_date,
         end_date: duration.end_date,
         price: price.value,
         med_cert_status: med_cert.status,
         payment_status: payment.status,
         status: status.status
       }}
    end
  end

  def decide(%MembershipAggregate{} = state, %ChangeMedicalCertificateStatus{
        status: new_status
      }) do
    with {:ok, med_cert} <- MedicalCertificateStatusValueObject.change(new_status) do
      {:ok,
       %MembershipMedicalCertificationStatusChanged{
         id: state.id,
         status: med_cert.status,
         previous_status: state.med_cert.status
       }}
    end
  end

  def decide(%MembershipAggregate{} = state, %ChangePaymentStatus{
        status: new_status
      }) do
    with {:ok, payment} <- PaymentStatusValueObject.change(new_status) do
      {:ok,
       %MembershipPaymentStatusChanged{
         id: state.id,
         status: payment.status,
         previous_status: state.payment.status
       }}
    end
  end

  def decide(
        %MembershipAggregate{id: id, med_cert: med_cert, payment: payment, status: current},
        %Activate{} = _
      ) do
    cond do
      not StatusValueObject.is_valid_state_transition?(current, :activated) ->
        {:error, DomainError.new(:invalid_state, "Invalid state transition")}

      not MedicalCertificateStatusValueObject.is_valid?(med_cert) ->
        {:error, DomainError.new(:invalid_state, "Invalid medical certificate")}

      is_nil(payment) ->
        {:ok, %MembershipActivated{id: id}}

      not PaymentStatusValueObject.is_paid?(payment) ->
        {:error, DomainError.new(:invalid_state, "Invalid payment status")}

      true ->
        {:ok, %MembershipActivated{id: id}}
    end
  end

  def apply_event(nil, %FreeMembershipApplicationSubmitted{} = event) do
    %FreeMembershipApplicationSubmitted{
      id: id,
      person_id: person_id,
      type: type,
      membership_type_id: membership_type_id,
      start_date: start_date,
      end_date: end_date,
      med_cert_status: med_cert_status,
      status: status
    } = event

    %MembershipAggregate{
      id: id,
      person_id: person_id,
      duration: %DurationValueObject{type: type, start_date: start_date, end_date: end_date},
      membership_type_id: membership_type_id,
      med_cert: %MedicalCertificateStatusValueObject{status: med_cert_status},
      status: %StatusValueObject{status: status},
      price: nil,
      payment: nil
    }
  end

  def apply_event(nil, %PaidMembershipApplicationSubmitted{} = event) do
    %PaidMembershipApplicationSubmitted{
      id: id,
      person_id: person_id,
      type: type,
      membership_type_id: membership_type_id,
      start_date: start_date,
      end_date: end_date,
      price: price,
      med_cert_status: med_cert_status,
      payment_status: payment_status,
      status: status
    } = event

    %MembershipAggregate{
      id: id,
      person_id: person_id,
      duration: %DurationValueObject{type: type, start_date: start_date, end_date: end_date},
      membership_type_id: membership_type_id,
      price: %PriceValueObject{value: price},
      med_cert: %MedicalCertificateStatusValueObject{status: med_cert_status},
      payment: %PaymentStatusValueObject{status: payment_status},
      status: %StatusValueObject{status: status}
    }
  end

  def apply_event(
        %MembershipAggregate{} = state,
        %MembershipMedicalCertificationStatusChanged{status: status}
      ) do
    %MembershipAggregate{
      state
      | med_cert: %MedicalCertificateStatusValueObject{status: status}
    }
  end

  def apply_event(%MembershipAggregate{} = state, %MembershipPaymentStatusChanged{status: status}) do
    %MembershipAggregate{
      state
      | payment: %PaymentStatusValueObject{status: status}
    }
  end

  def apply_event(%MembershipAggregate{} = state, %MembershipActivated{}) do
    %MembershipAggregate{
      state
      | status: %StatusValueObject{status: :activated}
    }
  end

  def evolve(state, command) do
    with {:ok, event} <- decide(state, command) do
      new_state = apply_event(state, event)
      {:ok, new_state, event}
    end
  end
end
