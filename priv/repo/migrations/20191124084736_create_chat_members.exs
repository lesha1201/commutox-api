defmodule CommutoxApi.Repo.Migrations.CreateChatMembers do
  use Ecto.Migration

  def change do
    create table(:chat_members) do
      add :last_read_at, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :chat_id, references(:chats, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:chat_members, [:user_id, :chat_id])
  end
end
