defmodule CommutoxApi.Chats.Domain.ListUserChatMembers do
  @moduledoc false

  alias Absinthe.Relay.Connection
  alias CommutoxApi.Repo
  alias CommutoxApi.Chats
  alias CommutoxApi.Types, as: T

  @type user :: %{id: T.id()}
  @type relay_options :: Connection.Options.t()
  @type result :: {:ok, Connection.t()} | {:error, any}

  @spec perform(user, relay_options) :: result
  def perform(user, args) do
    Chats.Query.user_chat_members(user.id)
    |> Connection.from_query(&Repo.all/1, args)
  end
end
