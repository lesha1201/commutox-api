defmodule CommutoxApiWeb.Resolvers.Account do
  alias Absinthe.Relay.Connection
  alias CommutoxApi.{Accounts, Repo}
  alias CommutoxApi.Accounts.{Contact, User}
  alias CommutoxApiWeb.Errors

  # Queries

  def list_users(args, %{context: %{current_user: _current_user}}) do
    User
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

  def list_contacts(args, %{context: %{current_user: current_user}}) do
    Contact.Query.user_contacts(current_user.id)
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_contacts(_, _) do
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

  def add_contact(args, %{context: %{current_user: current_user}}) do
    case Accounts.add_contact(%{
           current_user: current_user,
           contact_user: %{id: Map.get(args, :user_id), email: Map.get(args, :user_email)}
         }) do
      {:ok, contact} ->
        {:ok, %{contact: contact}}

      {:error, error} ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: [error]
           }
         })}
    end
  end

  def add_contact(_, _) do
    {:error, Errors.unauthorized()}
  end
end
