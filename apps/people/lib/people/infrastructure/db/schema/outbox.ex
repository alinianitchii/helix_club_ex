defmodule People.Infrastructure.Db.Schema.OutboxSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @statuses ~w(pending sent failed)

  schema "outbox_messages" do
    field :type, :string
    field :topic, :string
    field :payload, :map

    field :status, :string, default: "pending"
    field :locked_at, :utc_datetime_usec
    field :attempts, :integer, default: 0

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:type, :topic, :payload, :status, :locked_at, :attempts])
    |> validate_required([:type, :topic, :payload])
    |> validate_inclusion(:status, @statuses)
  end
end
