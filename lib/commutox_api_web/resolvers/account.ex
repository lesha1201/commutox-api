defmodule CommutoxApiWeb.Resolvers.Account do
  alias CommutoxApi.Accounts
  alias CommutoxApiWeb.Errors

  # Queries

  def list_users(args, %{context: %{current_user: _current_user}}) do
    case Accounts.list_users(args) do
      {:ok, result} ->
        {:ok, result}

      {:error, relay_error} ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{details: relay_error}
         })}
    end
  end

  def list_users(_, _) do
    {:error, Errors.unauthenticated()}
  end

  def user(_parent, %{email: email}, %{context: %{current_user: _current_user}}) do
    Accounts.get_user(email)
  end

  def user(_, _, _) do
    {:error, Errors.unauthenticated()}
  end

  # Mutations

  def sign_up(args, _) do
    case Accounts.sign_up(args) do
      {:error, :unknown} ->
        {:error, Errors.internal_error(%{message: "Can't sign up a user."})}

      result ->
        result
    end
  end

  def sign_in(args, _) do
    case Accounts.sign_in(args) do
      {:error, :unknown} ->
        {:error, Errors.internal_error(%{message: "Can't sign in a user."})}

      {:error, :invalid_credentials} ->
        {:error, Errors.invalid_input(%{message: "Invalid credentials."})}

      result ->
        result
    end
  end
end
