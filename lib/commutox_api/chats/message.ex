defmodule CommutoxApi.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.Chat

  schema "messages" do
    field :text, :string

    belongs_to :user, User
    belongs_to :chat, Chat

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:user_id, :chat_id, :text])
    |> validate_required([:user_id, :chat_id, :text])
  end
end
