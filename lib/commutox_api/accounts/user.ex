defmodule CommutoxApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string, unique: true
    field :full_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :email, :password])
    |> validate_required([:full_name, :email, :password])
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
