defmodule CommutoxApi.Accounts.Contact do
  use Ecto.Schema

  import Ecto.Changeset

  alias CommutoxApi.Accounts.{ContactStatus, User}

  schema "contacts" do
    %{code: default_status_code} = ContactStatus.Constants.pending()

    belongs_to :user_sender, User
    belongs_to :user_receiver, User

    field :status_code, :string, default: default_status_code

    belongs_to :status, ContactStatus,
      references: :code,
      foreign_key: :status_code,
      define_field: false

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:user_sender_id, :user_receiver_id, :status_code])
    |> validate_required([:user_sender_id, :user_receiver_id, :status_code])
    |> foreign_key_constraint(:user_sender_id)
    |> foreign_key_constraint(:user_receiver_id)
  end
end
