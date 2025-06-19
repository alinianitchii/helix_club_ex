defmodule People.Repo.Migrations.CreateOutboxTable do
  use Ecto.Migration

  def change do
      create table(:outbox_messages, primary_key: false) do
        add :id, :uuid, primary_key: true
        add :type, :string, null: false         # "event", "command"
        add :topic, :string, null: false
        add :payload, :map, null: false

        add :status, :string, default: "pending"   # "pending" | "sent" | "failed"
        add :locked_at, :utc_datetime_usec
        add :attempts, :integer, default: 0

        timestamps()
      end

      create index(:outbox_messages, [:status])
      create index(:outbox_messages, [:locked_at])
    end
end
