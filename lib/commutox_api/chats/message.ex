defmodule CommutoxApi.Chats.Message do
  use Ecto.Schema

  import Ecto.Changeset

  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.Chat

  @type t :: %__MODULE__{
          id: T.id() | nil,
          text: String.t() | nil,
          user_id: T.id() | nil,
          user: Ecto.Schema.belongs_to(User.t()),
          chat_id: T.id() | nil,
          chat: Ecto.Schema.belongs_to(Chat.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "messages" do
    field :text, :string

    belongs_to :user, User
    belongs_to :chat, Chat

    timestamps()
  end

  @fields [:user_id, :chat_id, :text]

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(message, attrs) do
    message
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_length(:text, min: 1)
  end
end
