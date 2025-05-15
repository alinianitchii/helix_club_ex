defmodule People.Repo.Migrations.CreateOutboxTable do
  use Ecto.Migration

  def change do
    create table(:outbox, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :aggregate_id, :string, null: false
      add :aggregate_type, :string, null: false
      add :event_type, :string, null: false
      add :payload, :jsonb, null: false
      add :metadata, :jsonb
      add :processed_at, :utc_datetime
      add :created_at, :utc_datetime, null: false
    end

    # Optional index for processing unhandled events efficiently
    create index(:outbox, [:processed_at])
  end
end
