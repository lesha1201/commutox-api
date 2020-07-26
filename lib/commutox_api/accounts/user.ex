defmodule CommutoxApi.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Chats.{Chat, ChatMember, Message}
  alias CommutoxApi.Contacts.Contact

  @type t :: %__MODULE__{
          id: T.id() | nil,
          email: String.t() | nil,
          full_name: String.t() | nil,
          password_hash: String.t() | nil,
          password: String.t() | nil,
          sent_contacts: Ecto.Schema.many_to_many(Contact.t()),
          received_contacts: Ecto.Schema.many_to_many(Contact.t()),
          messages: Ecto.Schema.has_many(Message.t()),
          chat_members: Ecto.Schema.has_many(ChatMember.t()),
          chats: Ecto.Schema.many_to_many(Chat.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "users" do
    field :email, :string, unique: true
    field :full_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    many_to_many :sent_contacts, __MODULE__,
      join_through: Contact,
      join_keys: [user_sender_id: :id, user_receiver_id: :id]

    many_to_many :received_contacts, __MODULE__,
      join_through: Contact,
      join_keys: [user_receiver_id: :id, user_sender_id: :id]

    has_many :messages, Message
    has_many :chat_members, ChatMember
    many_to_many :chats, Chat, join_through: ChatMember

    timestamps()
  end

  @fields [:full_name, :email, :password]

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_format(:email, ~r/^\S+@\S+$/)
    |> update_change(:email, &String.downcase(&1))
    |> validate_length(:password, min: 8, max: 64)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp hash_password(changeset), do: changeset
end
