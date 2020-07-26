defmodule CommutoxApi.Chats.Domain.SendMessageToUser do
  @moduledoc false

  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Accounts
  alias CommutoxApi.Chats.Domain.{SendMessage, CreateChat}

  @type result ::
          SendMessage.result()
          | {:error, :receiver_user_not_found | :unknown}
          | {:error, Ecto.Changeset.t()}

  @spec perform(%{id: T.id()}, %{user_id: T.id(), text: String.t()}) :: result
  def perform(%{id: user_receiver_id}, %{user_id: user_id, text: text}) do
    user_receiver = Accounts.Store.get_user(user_receiver_id)

    if user_receiver do
      case CreateChat.perform(%{}, [user_receiver_id, user_id]) do
        {:ok, chat} ->
          SendMessage.perform(%{user_id: user_id, chat_id: chat.id, text: text})

        {:error, error} ->
          {:error, error}
      end
    else
      {:error, :receiver_user_not_found}
    end
  end
end
