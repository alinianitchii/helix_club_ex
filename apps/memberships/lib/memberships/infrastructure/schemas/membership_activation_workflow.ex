defmodule Memberships.Infrastructure.Db.Schema.MembershipActivationWorkflow do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:process_id, :binary_id, autogenerate: false}
  schema "memberships_activation_workflow" do
    field :person_id, :string
    field :status, Ecto.Enum, values: [:in_progress]

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:process_id, :person_id, :status])
    |> validate_required([:process_id, :person_id, :status])
  end
end
