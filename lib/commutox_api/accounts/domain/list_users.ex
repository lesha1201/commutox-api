defmodule CommutoxApi.Accounts.Domain.ListUsers do
  @moduledoc false

  alias Absinthe.Relay.Connection
  alias CommutoxApi.Repo
  alias CommutoxApi.Accounts.{User}

  @type relay_options :: Connection.Options.t()
  @type result :: {:ok, Connection.t()} | {:error, any}

  @spec perform(relay_options) :: result
  def perform(args) do
    User
    |> Connection.from_query(&Repo.all/1, args)
  end
end
