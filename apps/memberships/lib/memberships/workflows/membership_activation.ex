defmodule Memberships.Workflows.MembershipActication do
  require Logger

  alias Memberships.Domain.Events.{
    FreeMembershipApplicationSubmitted,
    PaidMembershipApplicationSubmitted
  }

  alias Memberships.Workflows.Scheduler.TryActivateMembership
  alias Memberships.Infrastructure.Repositories.MembershipActivationWorkflow
  alias Memberships.Infrastructure.Db.Repo

  def handle(%FreeMembershipApplicationSubmitted{
        id: membership_id,
        person_id: person_id,
        start_date: start_date
      }) do
    process_state = %{process_id: membership_id, person_id: person_id, status: :in_progress}

    Repo.transaction(fn ->
      MembershipActivationWorkflow.upsert(process_state)
      TryActivateMembership.schedule(membership_id, start_date)
    end)

    request_medical_certificate(person_id)

    {:ok, process_state}
  end

  def handle(%PaidMembershipApplicationSubmitted{
        id: membership_id,
        person_id: person_id,
        start_date: start_date,
        price: price
      }) do
    process_state = %{process_id: membership_id, person_id: person_id, status: :in_progress}

    Repo.transaction(fn ->
      MembershipActivationWorkflow.upsert(process_state)
      TryActivateMembership.schedule(membership_id, start_date)
    end)

    request_medical_certificate(person_id)

    create_payment(membership_id, person_id, price, start_date)

    {:ok, process_state}
  end

  def handle(event) do
    Logger.debug("Unhandled event: #{inspect(event)}. Memberships.Workflows.MembershipActication")

    {:ok}
  end

  defp request_medical_certificate(person_id) do
    request_med_cert_cmd = %{
      type: :command,
      name: "medical-certificate.request",
      paylaod: %{holder_id: person_id}
    }

    PubSub.Integration.CommandBus.publish(request_med_cert_cmd)
  end

  defp create_payment(membership_id, person_id, price, start_date) do
    create_payment_cmd = %{
      type: :command,
      name: "payment.create",
      paylaod: %{
        product_id: membership_id,
        customer_id: person_id,
        amount: price,
        due_date: start_date
      }
    }

    PubSub.Integration.CommandBus.publish(create_payment_cmd)
  end
end
