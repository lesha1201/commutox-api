defmodule CommutoxApi.Accounts.Domain.SignIn do
  @moduledoc false

  alias CommutoxApi.Accounts
  alias CommutoxApi.Accounts.{User}

  @type args :: %{email: String.t(), password: String.t()}
  @type result :: {:ok, %{user: User.t(), token: String.t()}} | {:error, any}

  @spec perform(args) :: result
  def perform(args) do
    with {:ok, user} <- Accounts.Session.authenticate(args),
         {:ok, jwt_token, _} <- Accounts.Guardian.encode_and_sign(user) do
      {:ok, %{user: user, token: jwt_token}}
    else
      {:error, error} ->
        {:error, error}

      :error ->
        {:error, :unknown}
    end
  end
end
