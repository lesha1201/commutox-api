defmodule CommutoxApi.Chats.ChatMember do
  use Ecto.Schema

  import Ecto.Changeset

  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.Chat

  @type t :: %__MODULE__{
          id: T.id() | nil,
          last_read_at: NaiveDateTime.t() | nil,
          user_id: T.id() | nil,
          user: Ecto.Schema.belongs_to(User.t()),
          chat_id: T.id() | nil,
          chat: Ecto.Schema.belongs_to(Chat.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "chat_members" do
    field :last_read_at, :naive_datetime

    belongs_to :user, User
    belongs_to :chat, Chat

    timestamps()
  end

  @required_fields [:user_id, :chat_id]
  @fields @required_fields ++ [:last_read_at]

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(chat_member, attrs) do
    chat_member
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:user_id_chat_id)
  end
end
