defmodule People.Infrastructure.Db.Repo.Migrations.AddMedicalCertificates do
  use Ecto.Migration

    def change do
      create table(:medical_certificates, primary_key: false) do
        add :id, :binary_id, primary_key: true
        add :holder_id, :string, null: false
        add :holder_name, :string
        add :holder_surname, :string
        add :request_date, :date
        add :issue_date, :date
        add :status, :string, null: false

        timestamps()
      end
    end
end
