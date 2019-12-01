defmodule CommutoxApi.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.{ChatMember, Message}

  schema "chats" do
    has_many :members, ChatMember
    has_many :messages, Message
    many_to_many :users, User, join_through: ChatMember

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [])
    |> validate_required([])
  end
end
