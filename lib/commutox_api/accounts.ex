defmodule CommutoxApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Accounts.Domain.{GetUser, ListUsers, SignIn, SignUp}

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user(current_user)
      %User{}
  """
  @spec get_user(String.t()) :: {:ok, User.t()}
  def get_user(email) do
    GetUser.perform(email)
  end

  @doc """
  Returns all users in the system.

  ## Examples

      iex> list_users()
      {
        :ok,
        %{
          edges: [%{node: %User{}, cursor: cursor}],
          page_info: page_info
        }
      }
  """
  @spec list_users(ListUsers.relay_options()) ::
          ListUsers.result()
  def list_users(args \\ %{}) do
    ListUsers.perform(args)
  end

  @doc """
  Signs in a user.

  ## Examples

      iex> sign_in(%{email: "test@test", password: "123"})
      {:ok, %{user: %User{}, token: "token"}}
  """
  @spec sign_in(SignIn.args()) :: SignIn.result()
  def sign_in(args) do
    SignIn.perform(args)
  end

  @doc """
  Signs up a new user.

  ## Examples

      iex> sign_up(user_args)
      {:ok, %{user: %User{}, token: "token"}}
  """
  @spec sign_up(map) :: SignUp.result()
  def sign_up(args) do
    SignUp.perform(args)
  end
end
