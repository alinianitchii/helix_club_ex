defmodule People.Infrastructure.Db.Repo.Migrations.CreatePeopleReadModel do
  use Ecto.Migration

  def change do
      create table(:people_read_model, primary_key: false) do
        add :id, :uuid, primary_key: true
        add :name, :string
        add :surname, :string
        add :email, :string
        add :date_of_birth, :date
        add :address, :jsonb

        timestamps()
      end
  end
end
