defmodule CommutoxApiWeb.Resolvers.Account do
  alias CommutoxApi.{Accounts}

  # Queries

  def users(_parent, _args, _resolution) do
    {:ok, Accounts.list_users()}
  end

  def user(_parent, %{email: email}, _resolution) do
    {:ok, Accounts.get_user_by(email: email)}
  end

  # Mutations

  def sign_up(args, _) do
    with {:ok, user} <- Accounts.create_user(args),
         {:ok, jwt_token, _} <- Accounts.Guardian.encode_and_sign(user) do
      {:ok, %{user: user, token: jwt_token}}
    else
      {:error, error} -> {:error, error}
      :error -> {:error, "Can't sign up a user."}
    end
  end

  def sign_in(args, _) do
    with {:ok, user} <- Accounts.Session.authenticate(args),
         {:ok, jwt_token, _} <- Accounts.Guardian.encode_and_sign(user) do
      {:ok, %{user: user, token: jwt_token}}
    else
      {:error, error} -> {:error, error}
      :error -> {:error, "Can't sign in a user."}
    end
  end
end
