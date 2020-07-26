defmodule CommutoxApi.Contacts.Contact do
  use Ecto.Schema

  import Ecto.Changeset

  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Contacts.{ContactStatus, Constants}

  @type t :: %__MODULE__{
          id: T.id() | nil,
          user_sender_id: T.id() | nil,
          user_sender: Ecto.Schema.belongs_to(User.t()),
          user_receiver_id: T.id() | nil,
          user_receiver: Ecto.Schema.belongs_to(User.t()),
          status_code: String.t() | nil,
          status: Ecto.Schema.belongs_to(ContactStatus.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "contacts" do
    %{code: default_status_code} = Constants.pending()

    belongs_to :user_sender, User
    belongs_to :user_receiver, User

    field :status_code, :string, default: default_status_code

    belongs_to :status, ContactStatus,
      references: :code,
      foreign_key: :status_code,
      define_field: false

    timestamps()
  end

  @fields [:user_sender_id, :user_receiver_id, :status_code]

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:user_sender_id)
    |> foreign_key_constraint(:user_receiver_id)
  end
end
