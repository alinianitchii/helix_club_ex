defmodule Memberships.Infrastructure.Db.Repo.Migrations.MembershipsReadModel do
  use Ecto.Migration

  def change do
 		create table(:memberships_read_model, primary_key: false) do
 			add :id, :uuid, primary_key: true
 	 		add :person_id, :string
 	  	add :type, :string
     	add :start_date, :date
      add :end_date, :date

     	timestamps()
  	end
  end
end
