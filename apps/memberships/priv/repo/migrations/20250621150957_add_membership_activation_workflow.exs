defmodule Memberships.Infrastructure.Db.Repo.Migrations.AddMembershipActivationWorkflow do
  use Ecto.Migration

  def change do
  create table(:memberships_activation_workflow, primary_key: false) do
  	add :process_id, :uuid, primary_key: true
    add :person_id, :string, null: false
    add :status, :string, null: false

    timestamps()
  end
  end
end
