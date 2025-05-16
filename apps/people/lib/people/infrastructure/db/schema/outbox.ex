defmodule People.Infrastructure.Db.Schema.OutboxSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "outbox" do
    field(:aggregate_id, :string)
    field(:aggregate_type, :string)
    field(:event_type, :string)
    # JSON type
    field(:payload, :map)
    # JSON type
    field(:metadata, :map)
    field(:published_at, :utc_datetime)
    field(:created_at, :utc_datetime)
  end

  def changeset(outbox, attrs) do
    outbox
    |> cast(attrs, [:aggregate_id, :aggregate_type, :event_type, :payload, :metadata, :created_at])
    |> validate_required([:aggregate_id, :aggregate_type, :event_type, :payload, :created_at])
  end
end
