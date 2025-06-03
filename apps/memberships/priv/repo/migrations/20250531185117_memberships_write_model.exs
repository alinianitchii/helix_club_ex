defmodule Memberships.Infrastructure.Db.Repo.Migrations.CreateMembershipsWriteModel do
  use Ecto.Migration

  def change do
  	create table(:memberships_write_model, primary_key: false) do
  		add :id, :string, primary_key: true
  	 	add :state, :jsonb, null: false
  	  add :version, :integer, default: 1, null: false

     timestamps()
   	end
  end
end
