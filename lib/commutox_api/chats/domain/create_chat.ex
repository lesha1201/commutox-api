defmodule CommutoxApi.Chats.Domain.CreateChat do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias CommutoxApi.Repo
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats
  alias CommutoxApi.Chats.Chat
  alias CommutoxApi.Types, as: T

  @type result :: {:ok, Chat.t()} | {:error, Ecto.Changeset.t()} | {:error, :unknown}

  @spec perform(map, list(T.id())) :: result
  def perform(attrs, user_ids \\ []) do
    case Repo.one(Chats.Query.chat_with_users(user_ids)) do
      nil ->
        create_chat(attrs, user_ids)

      chat ->
        {:ok, chat}
    end
  end

  defp create_chat(attrs, user_ids) do
    users = from(u in User, where: u.id in ^user_ids, select: [:id]) |> Repo.all()

    chat_changeset = Chat.changeset(%Chat{}, attrs)
    chat_users_changeset = Ecto.Changeset.put_assoc(chat_changeset, :users, users)

    Multi.new()
    |> Multi.insert(:chat, chat_users_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{chat: chat}} ->
        {:ok, chat}

      {:error, :chat, changeset, _} ->
        {:error, changeset}

      _ ->
        {:error, :unknown}
    end
  end
end
