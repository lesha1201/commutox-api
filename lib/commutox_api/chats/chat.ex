defmodule CommutoxApi.Chats.Chat do
  use Ecto.Schema

  import Ecto.Changeset

  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.{ChatMember, Message}

  @type t :: %__MODULE__{
          id: T.id() | nil,
          members: Ecto.Schema.has_many(ChatMember.t()),
          messages: Ecto.Schema.has_many(Message.t()),
          users: Ecto.Schema.many_to_many(User.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "chats" do
    has_many :members, ChatMember
    has_many :messages, Message
    many_to_many :users, User, join_through: ChatMember

    timestamps()
  end

  @fields []

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
