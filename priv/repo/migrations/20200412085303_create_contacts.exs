defmodule CommutoxApi.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :user_sender_id, references(:users, on_delete: :delete_all), null: false
      add :user_receiver_id, references(:users, on_delete: :delete_all), null: false

      add :status_code,
          references(:contact_statuses, column: :code, type: :string, on_delete: :nothing),
          null: false

      timestamps()
    end

    create unique_index(:contacts, [
             "least(user_sender_id, user_receiver_id)",
             "greatest(user_sender_id, user_receiver_id)"
           ])

    create index(:contacts, [:status_code])
  end
end
