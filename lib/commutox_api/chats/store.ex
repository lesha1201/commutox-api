defmodule CommutoxApi.Chats.Store do
  @moduledoc """
  Database CRUD operations for Chats context.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Repo
  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Chats.{Chat, ChatMember, Message}

  # ********
  # * Chat *
  # ********

  @spec list_chats :: list(Chat.t())
  def list_chats do
    Repo.all(Chat)
  end

  @spec get_chat(T.id()) :: Chat.t() | nil
  def get_chat(id), do: Repo.get(Chat, id)

  @spec(get_chat_by(keyword()) :: Chat.t(), nil)
  def get_chat_by(clauses), do: Repo.get_by(Chat, clauses)

  @spec create_chat(map) :: {:ok, Chat.t()} | {:error, Ecto.Changeset.t()}
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_chat(Chat.t(), map) :: {:ok, Chat.t()} | {:error, Ecto.Changeset.t()}
  def update_chat(%Chat{} = contact, attrs) do
    contact
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_chat(Chat.t()) :: {:ok, Chat.t()} | {:error, Ecto.Changeset.t()}
  def delete_chat(%Chat{} = contact) do
    Repo.delete(contact)
  end

  # ***************
  # * Chat Member *
  # ***************

  @spec list_chat_members :: list(ChatMember.t())
  def list_chat_members do
    Repo.all(ChatMember)
  end

  @spec get_chat_member(T.id()) :: ChatMember.t() | nil
  def get_chat_member(id), do: Repo.get(ChatMember, id)

  @spec(get_chat_member_by(keyword()) :: ChatMember.t(), nil)
  def get_chat_member_by(clauses), do: Repo.get_by(ChatMember, clauses)

  @spec create_chat_member(map) :: {:ok, ChatMember.t()} | {:error, Ecto.Changeset.t()}
  def create_chat_member(attrs \\ %{}) do
    %ChatMember{}
    |> ChatMember.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_chat_member(ChatMember.t(), map) ::
          {:ok, ChatMember.t()} | {:error, Ecto.Changeset.t()}
  def update_chat_member(%ChatMember{} = contact, attrs) do
    contact
    |> ChatMember.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_chat_member(ChatMember.t()) :: {:ok, ChatMember.t()} | {:error, Ecto.Changeset.t()}
  def delete_chat_member(%ChatMember{} = contact) do
    Repo.delete(contact)
  end

  # ***********
  # * Message *
  # ***********

  @spec list_messages :: list(Message.t())
  def list_messages do
    Repo.all(Message)
  end

  @spec get_message(T.id()) :: Message.t() | nil
  def get_message(id), do: Repo.get(Message, id)

  @spec(get_message_by(keyword()) :: Message.t(), nil)
  def get_message_by(clauses), do: Repo.get_by(Message, clauses)

  @spec create_message(map) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_message(Message.t(), map) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def update_message(%Message{} = contact, attrs) do
    contact
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_message(Message.t()) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def delete_message(%Message{} = contact) do
    Repo.delete(contact)
  end
end
