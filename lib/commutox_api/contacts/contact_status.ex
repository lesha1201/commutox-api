defmodule CommutoxApi.Contacts.ContactStatus do
  use Ecto.Schema

  import Ecto.Changeset

  @type code :: String.t()

  @type t :: %__MODULE__{
          code: code | nil,
          name: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @primary_key {:code, :string, autogenerate: false}
  @foreign_key_type :string
  @derive {Phoenix.Param, key: :code}
  schema "contact_statuses" do
    field :name, :string

    timestamps()
  end

  @fields [:code, :name]

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(contact_status, attrs) do
    contact_status
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:name)
  end
end
