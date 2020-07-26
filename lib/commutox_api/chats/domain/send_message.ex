defmodule CommutoxApi.Chats.Domain.SendMessage do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias CommutoxApi.Repo
  alias CommutoxApi.Accounts
  alias CommutoxApi.Chats
  alias CommutoxApi.Chats.{Message}
  alias CommutoxApi.Types, as: T

  @type error :: :unknown | :user_not_in_chat | :chat_not_found | :user_not_found
  @type attrs :: %{chat_id: T.id(), user_id: T.id(), text: String.t()}

  @type result ::
          {:ok, Message.t()}
          | {:error, error}
          | {:error, Ecto.Changeset.t()}

  @spec perform(attrs) :: result
  def perform(attrs) do
    message_changeset = Message.changeset(%Message{}, attrs)

    Multi.new()
    |> validate_user_existence(attrs.user_id)
    |> validate_chat_existence(attrs.chat_id)
    |> validate_user_in_chat(%{user_id: attrs.user_id, chat_id: attrs.chat_id})
    |> Multi.insert(:message, message_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} ->
        {:ok, message}

      {:error, :message, changeset, _} ->
        {:error, changeset}

      {:error, :validate_user_existence, reason, _} ->
        {:error, reason}

      {:error, :validate_chat_existence, reason, _} ->
        {:error, reason}

      {:error, :validate_user_in_chat, reason, _} ->
        {:error, reason}

      _ ->
        {:error, :unknown}
    end
  end

  defp validate_user_existence(multi, user_id) do
    Multi.run(multi, :validate_user_existence, fn _repo, _changes ->
      case Accounts.Store.get_user(user_id) do
        nil ->
          {:error, :user_not_found}

        user ->
          {:ok, user}
      end
    end)
  end

  defp validate_chat_existence(multi, chat_id) do
    Multi.run(multi, :validate_chat_existence, fn _repo, _changes ->
      case Chats.Store.get_chat(chat_id) do
        nil ->
          {:error, :chat_not_found}

        chat ->
          {:ok, chat}
      end
    end)
  end

  defp validate_user_in_chat(multi, %{user_id: user_id, chat_id: chat_id}) do
    Multi.run(multi, :validate_user_in_chat, fn repo, _changes ->
      case repo.one(Chats.Query.user_chat(user_id, chat_id)) do
        nil ->
          {:error, :user_not_in_chat}

        chat ->
          {:ok, chat}
      end
    end)
  end
end
