defmodule CommutoxApiWeb.Resolvers.Account do
  alias Absinthe.Relay.Connection
  alias CommutoxApi.{Accounts, Repo}
  alias CommutoxApiWeb.Errors

  # Queries

  def list_users(args, %{context: %{current_user: _current_user}}) do
    Accounts.User
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_users(_, _) do
    {:error, Errors.unauthorized()}
  end

  def user(_parent, %{email: email}, %{context: %{current_user: _current_user}}) do
    {:ok, Accounts.get_user_by(email: email)}
  end

  def user(_, _, _) do
    {:error, Errors.unauthorized()}
  end

  # Mutations

  def sign_up(args, _) do
    with {:ok, user} <- Accounts.create_user(args),
         {:ok, jwt_token, _} <- Accounts.Guardian.encode_and_sign(user) do
      {:ok, %{user: user, token: jwt_token}}
    else
      {:error, error} ->
        {:error, error}

      :error ->
        {:error, "Can't sign up a user."}
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
