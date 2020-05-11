defmodule CommutoxApi.Accounts.ContactStatus do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:code, :string, autogenerate: false}
  @foreign_key_type :string
  @derive {Phoenix.Param, key: :code}
  schema "contact_statuses" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(contact_status, attrs) do
    contact_status
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:name)
  end
end
