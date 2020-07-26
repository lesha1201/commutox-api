defmodule CommutoxApi.Accounts.Store do
  @moduledoc """
  Database CRUD operations for Accounts context.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Repo
  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Accounts.User

  # ********
  # * User *
  # ********

  @spec list_users :: list(User.t())
  def list_users do
    Repo.all(User)
  end

  @spec get_user(T.id()) :: User.t() | nil
  def get_user(id), do: Repo.get(User, id)

  @spec get_user_by(keyword) :: User.t() | nil
  def get_user_by(clauses), do: Repo.get_by(User, clauses)

  @spec create_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = contact, attrs) do
    contact
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = contact) do
    Repo.delete(contact)
  end
end
