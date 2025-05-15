defmodule People.Infrastructure.Db.Schema.PersonWriteModel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "people_write_model" do
    # This will use Postgres JSONB type
    field(:state, :map)
    # For optimistic concurrency control
    field(:version, :integer, default: 1)

    timestamps()
  end

  def changeset(person, attrs) do
    person
    |> cast(attrs, [:id, :state, :version])
    |> validate_required([:id, :state, :version])
    |> optimistic_lock(:version)
  end
end
