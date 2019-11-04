defmodule CommutoxApiWeb.Resolvers.Account do
  alias CommutoxApi.{Accounts}

  # Queries

  def users(_parent, _args, _resolution) do
    {:ok, Accounts.list_users()}
  end

  def user(_parent, %{email: email}, _resolution) do
    {:ok, Accounts.get_user_by_email(email)}
  end

  # Mutations

  def create_user(args, _) do
    case Accounts.create_user(args) do
      {:ok, user} ->
        {:ok, %{user: user}}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "Can't create a user."}
    end
  end
end
