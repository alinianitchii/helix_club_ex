defmodule Memberships.Infrastructure.Db.Schema.MembershipWriteModel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "memberships_write_model" do
    field(:state, :map)
    field(:version, :integer, default: 1)

    timestamps()
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:id, :state, :version])
    |> validate_required([:id, :state, :version])
    |> optimistic_lock(:version)
  end
end
