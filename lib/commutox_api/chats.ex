defmodule CommutoxApi.Chats do
  @moduledoc """
  The Chats context.
  """

  alias CommutoxApi.Chats.Domain.{
    CreateChat,
    SendMessage,
    SendMessageToUser,
    ListUserChatMembers,
    ListUserChats,
    ListUserMessages
  }

  alias CommutoxApi.Types, as: T

  @doc """
  Creates a chat or returns an existing chat with provided users.

  ## Examples

      iex> create_chat(%{field: value}, [1, 2])
      {:ok, %Chat{id: 1}} # Creates

      iex> create_chat(%{field: value}, [1, 2])
      {:ok, %Chat{id: 1}} # Returns

      iex> create_chat(%{field: bad_value}, [])
      {:error, %Ecto.Changeset{}}

  """
  @spec create_chat(map, list(T.id())) :: CreateChat.result()
  def create_chat(attrs \\ %{}, users \\ []) do
    CreateChat.perform(attrs, users)
  end

  @doc """
  Sends a message to a chat. Validates that the sender user is in the chat.

  ## Examples

      iex> send_message(attrs)
      {:ok, %Message{}}

      iex> send_message(attrs)
      {:error, :user_not_in_chat}

  """
  @spec send_message(SendMessage.attrs()) :: SendMessage.result()
  def send_message(attrs) do
    SendMessage.perform(attrs)
  end

  @doc """
  Sends a message to a user. If a chat doesn't exist between the users then it will
  create a new one.

  ## Examples

      iex> send_message_to_user(attrs)
      {:ok, %Message{}}

      iex> send_message_to_user(attrs)
      {:error, :receiver_user_not_found}

  """
  @spec send_message_to_user(%{id: T.id()}, %{user_id: T.id(), text: String.t()}) ::
          SendMessageToUser.result()
  def send_message_to_user(user, message) do
    SendMessageToUser.perform(user, message)
  end

  @doc """
  Returns the `user`'s chats in Relay representation.

  ## Examples

      iex> list_user_chats(current_user)
      {
        :ok,
        %{
          edges: [%{node: %Chat{}, cursor: cursor}],
          page_info: page_info
        }
      }
  """
  @spec list_user_chats(ListUserChats.user(), ListUserChats.relay_options()) ::
          ListUserChats.result()
  def list_user_chats(user, args \\ %{}) do
    ListUserChats.perform(user, args)
  end

  @doc """
  Returns the `user`'s chat members in Relay representation.

  ## Examples

      iex> list_user_chats(current_user)
      {
        :ok,
        %{
          edges: [%{node: %ChatMember{}, cursor: cursor}],
          page_info: page_info
        }
      }
  """
  @spec list_user_chat_members(ListUserChatMembers.user(), ListUserChatMembers.relay_options()) ::
          ListUserChatMembers.result()
  def list_user_chat_members(user, args \\ %{}) do
    ListUserChatMembers.perform(user, args)
  end

  @doc """
  Returns visible messages for the `user` in Relay representation.

  ## Examples

      iex> list_user_messages(current_user)
      {
        :ok,
        %{
          edges: [%{node: %Message{}, cursor: cursor}],
          page_info: page_info
        }
      }
  """
  @spec list_user_messages(ListUserMessages.user(), ListUserMessages.relay_options()) ::
          ListUserMessages.result()
  def list_user_messages(user, args \\ %{}) do
    ListUserMessages.perform(user, args)
  end
end
