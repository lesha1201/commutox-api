defmodule CommutoxApi.Repo.Migrations.CreateContactStatuses do
  use Ecto.Migration

  def change do
    create table(:contact_statuses, primary_key: false) do
      add :code, :string, size: 3, primary_key: true
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:contact_statuses, [:name])
  end
end
