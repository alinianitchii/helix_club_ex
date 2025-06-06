defmodule Memberships.Repo.Migrations.CreateMembershipTypes do
  use Ecto.Migration

  def change do
    create table(:membership_types, primary_key: false) do
    	add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :description, :text
      add :price, :float
      add :archived, :boolean, default: false

      timestamps()
    end

    create unique_index(:membership_types, [:name, :type], where: "archived = false") # ecto generates an indeex name like this :membership_types_name_type_index
  end
end
