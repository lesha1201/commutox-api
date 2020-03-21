defmodule CommutoxApi.Chats.Message.CreateMessage do
  @moduledoc """
  Contains business logic for creating a message.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias CommutoxApi.Repo
  alias CommutoxApi.Chats.{Message, Chat}

  def perform(attrs \\ %{user_id: nil, chat_id: nil}) do
    message_changeset = Message.changeset(%Message{}, attrs)

    Multi.new()
    |> Multi.insert(:message, message_changeset)
    |> validate_user_in_chat(%{user_id: attrs.user_id, chat_id: attrs.chat_id})
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} ->
        {:ok, message}

      {:error, :message, changeset, _} ->
        {:error, changeset}

      {:error, :validate_user_in_chat, reason, _} ->
        {:error, reason}

      _ ->
        {:error, "Something went wrong."}
    end
  end

  defp validate_user_in_chat(multi, %{user_id: user_id, chat_id: chat_id}) do
    Multi.run(multi, :validate_user_in_chat, fn repo, _changes ->
      case repo.one(Chat.Query.user_chat(user_id, chat_id)) do
        nil ->
          {:error, "User isn't in the chat."}

        chat ->
          {:ok, chat}
      end
    end)
  end
end
