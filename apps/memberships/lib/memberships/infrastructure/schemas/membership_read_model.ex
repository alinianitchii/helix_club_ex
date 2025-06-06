defmodule Memberships.Infrastructure.Db.Schema.MembershipReadModel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "memberships_read_model" do
    field :person_id, :string
    field :type, :string
    field :membership_type_id, :string
    field :start_date, :date
    field :end_date, :date
    field :price, :float

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:id, :person_id, :type, :membership_type_id, :start_date, :end_date])
    |> validate_required([:id, :person_id, :type, :membership_type_id, :start_date, :end_date])
  end
end
