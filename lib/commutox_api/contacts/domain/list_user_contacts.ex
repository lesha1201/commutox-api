defmodule CommutoxApi.Contacts.Domain.ListUserContacts do
  @moduledoc false

  alias Absinthe.Relay.Connection
  alias CommutoxApi.Repo
  alias CommutoxApi.Contacts
  alias CommutoxApi.Types, as: T

  @type user :: %{id: T.id()}
  @type relay_options :: Connection.Options.t()
  @type result :: {:ok, Connection.t()} | {:error, any}

  @spec perform(user, relay_options) :: result
  def perform(user, args) do
    Contacts.Query.user_contacts(user.id)
    |> Connection.from_query(&Repo.all/1, args)
  end
end
