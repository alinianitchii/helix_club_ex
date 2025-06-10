defmodule Payments.Infrastructure.Db.Schema.PaymentReadModel do
  use Ecto.Schema
  import Ecto.Changeset

  # TODO: find out if its the right way to do this
  @derive {Jason.Encoder,
           only: [
             :id,
             :amount,
             :due_date,
             :status,
             :customer_id,
             :product_id,
             :cashed_date,
             :inserted_at,
             :updated_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "payments_read_model" do
    field(:amount, :float)
    field(:due_date, :date)
    field(:status, :string)
    field(:customer_id, :binary_id)
    field(:product_id, :binary_id)
    field(:cashed_date, :date)

    timestamps()
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :id,
      :amount,
      :due_date,
      :status,
      :customer_id,
      :product_id,
      :cashed_date
    ])
    |> validate_required([:id, :amount, :due_date, :status, :customer_id, :product_id])
    |> validate_inclusion(:status, ["pending", "paid", "overdue", "canceled"])
    |> validate_number(:amount, greater_than: 0)
  end
end
