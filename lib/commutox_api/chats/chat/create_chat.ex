defmodule CommutoxApi.Chats.Chat.CreateChat do
  @moduledoc """
  Contains business logic for creating a chat.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias CommutoxApi.Repo
  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.Chat

  @doc """
  Checks if there is a chat with `user_ids`.
  If there is then it returns otherwise creates a new one
  """
  def perform(attrs, user_ids \\ []) do
    case Repo.one(Chat.Query.chat_with_users(user_ids)) do
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
        {:error, "Something went wrong."}
    end
  end
end
