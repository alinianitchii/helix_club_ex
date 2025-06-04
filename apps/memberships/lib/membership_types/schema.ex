# Find out convetions of module names
defmodule Memberships.Infrastructure.Db.Schema.MembershipType do
  use Ecto.Schema
  import Ecto.Changeset

  @membership_types ~w(yearly quarterly monthly)a

  @derive {Jason.Encoder, only: [:id, :name, :type, :description, :price_id, :archived]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "membership_types" do
    field :name, :string
    field :type, Ecto.Enum, values: @membership_types
    field :description, :string
    field :price_id, :string
    field :archived, :boolean, default: false

    timestamps()
  end

  def changeset(mem_type, attrs) do
    mem_type
    |> cast(attrs, [:name, :type, :description, :price_id, :archived])
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @membership_types)
    |> unique_constraint(:name, name: :membership_types_name_type_index)
  end
end
