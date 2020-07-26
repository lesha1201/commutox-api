defmodule CommutoxApi.Accounts.Domain.SignUp do
  @moduledoc false

  alias CommutoxApi.Accounts
  alias CommutoxApi.Accounts.{User}

  @type result :: {:ok, %{user: User.t(), token: String.t()}} | {:error, any}

  @spec perform(map) :: result
  def perform(args) do
    with {:ok, user} <- Accounts.Store.create_user(args),
         {:ok, jwt_token, _} <- Accounts.Guardian.encode_and_sign(user) do
      {:ok, %{user: user, token: jwt_token}}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:error, :unknown}
    end
  end
end
