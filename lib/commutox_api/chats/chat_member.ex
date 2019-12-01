defmodule CommutoxApi.Chats.ChatMember do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.Chat

  schema "chat_members" do
    field :last_read_at, :naive_datetime

    belongs_to :user, User
    belongs_to :chat, Chat

    timestamps()
  end

  @doc false
  def changeset(chat_member, attrs) do
    chat_member
    |> cast(attrs, [:user_id, :chat_id, :last_read_at])
    |> validate_required([:user_id, :chat_id])
    |> unique_constraint(:user_id_chat_id)
  end
end
