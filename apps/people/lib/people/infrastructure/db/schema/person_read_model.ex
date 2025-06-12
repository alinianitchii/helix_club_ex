defmodule People.Infrastructure.Db.Schema.PersonReadModel do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :surname,
             :email,
             :date_of_birth,
             :address,
             :inserted_at,
             :updated_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "people_read_model" do
    field :name, :string
    field :surname, :string
    field :email, :string
    field :date_of_birth, :date
    field :address, :map

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:id, :name, :surname, :email, :date_of_birth, :address])
    |> validate_required([:id, :name, :surname, :email])
  end
end
