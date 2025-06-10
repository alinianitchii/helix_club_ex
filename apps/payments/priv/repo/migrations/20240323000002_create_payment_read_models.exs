defmodule Payments.Infrastructure.Db.Repo.Migrations.CreatePaymentsReadModel do
  use Ecto.Migration

  def change do
    create table(:payments_read_model, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :float, null: false
      add :due_date, :date, null: false
      add :status, :string, null: false
      add :customer_id, :binary_id, null: false
      add :product_id, :binary_id, null: false
      add :cashed_date, :date

      timestamps()
    end
  end
end
