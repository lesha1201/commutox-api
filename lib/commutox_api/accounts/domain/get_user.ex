defmodule CommutoxApi.Accounts.Domain.GetUser do
  @moduledoc false

  alias CommutoxApi.Accounts
  alias CommutoxApi.Accounts.{User}

  @spec perform(String.t()) :: {:ok, User.t()}
  def perform(email) do
    {:ok, Accounts.Store.get_user_by(email: email)}
  end
end
