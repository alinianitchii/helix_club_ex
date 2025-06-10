defmodule Payments.Infrastructure.Db.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
  	create table(:payments_write_model, primary_key: false) do
  		add :id, :string, primary_key: true
  	 	add :state, :jsonb, null: false
  	  add :version, :integer, default: 1, null: false

     timestamps()
   	end
  end
end
