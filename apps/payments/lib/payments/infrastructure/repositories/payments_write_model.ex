defmodule Payments.Infrastructure.Repositories.PaymentsWriteRepo do
  alias Payments.Infrastructure.Db.Schema.PaymentWriteModel
  alias Payments.Infrastructure.Db.Repo
  alias Payments.Domain.PaymentAggregate
  alias Payments.Domain.ValueObjects

  def save(payment, events) when is_list(events) do
    payment_json = serialize_aggregate(payment)

    payment_changeset =
      case Repo.get(PaymentWriteModel, payment.id) do
        nil ->
          %PaymentWriteModel{id: payment.id}
          |> PaymentWriteModel.changeset(%{state: payment_json})

        existing ->
          existing
          |> PaymentWriteModel.changeset(%{state: payment_json})
      end

    Repo.insert_or_update(payment_changeset)
  end

  def save(payment), do: save(payment, [])

  # This is here because of the evolve function. When it does not returns any event it retuns nil.
  # and it is a list because the command punts it there. Its not good.
  def save_and_publish(payment, [nil]), do: save_and_publish(payment, [])

  def save_and_publish(payment, events) do
    case save(payment) do
      {:ok, _} ->
        Enum.each(events, &Payments.EventBus.publish/1)
        {:ok, payment}

      error ->
        error
    end
  end

  def get(id) do
    case Repo.get(PaymentWriteModel, id) do
      nil ->
        {:error, :not_found}

      payment_schema ->
        # Deserialize the state from JSON to the aggregate
        payment = deserialize_aggregate(payment_schema.state)
        {:ok, payment}
    end
  end

  defp serialize_aggregate(payment) do
    %{
      "id" => payment.id,
      "customer_id" => payment.customer_id,
      "product_id" => payment.product_id,
      "due_date" => %{
        "date" => Date.to_iso8601(payment.due_date.date)
      },
      "amount" => %{"value" => payment.amount.value},
      "status" => %{"status" => payment.status.status}
    }
  end

  defp deserialize_aggregate(payment_json) do
    IO.inspect(payment_json)

    %PaymentAggregate{
      id: payment_json["id"],
      customer_id: payment_json["customer_id"],
      product_id: payment_json["product_id"],
      due_date: %ValueObjects.DueDate{
        date: deserialize_date(payment_json["due_date"]["date"])
      },
      amount: %ValueObjects.Amount{value: payment_json["amount"]["value"]},
      status: %ValueObjects.Status{status: payment_json["status"]["status"]}
    }
  end

  defp deserialize_date(nil), do: nil
  defp deserialize_date(date_string), do: Date.from_iso8601!(date_string)
end
