defmodule MedicalCertificates.Infrastructure.Db.Schema.MedicalCertificate do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :holder_id,
             :holder_name,
             :holder_surname,
             :request_date,
             :issue_date,
             :status,
             :inserted_at,
             :updated_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "medical_certificates" do
    field :holder_id, :string
    field :holder_name, :string
    field :holder_surname, :string
    field :request_date, :date
    field :issue_date, :date
    field :status, Ecto.Enum, values: [:unknown, :valid, :invalid]

    timestamps()
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [
      :id,
      :holder_id,
      :holder_name,
      :holder_surname,
      :request_date,
      :issue_date,
      :status
    ])
    |> validate_required([:holder_id, :status])
  end
end
