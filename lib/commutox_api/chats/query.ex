defmodule CommutoxApi.Chats.Query do
  @moduledoc """
  SQL queries related to Chats context.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.{Chat, ChatMember, Message}
  alias CommutoxApi.Types, as: T

  @doc """
  Finds a chat with certain users.
  """
  @spec chat_with_users(list(T.id())) :: Ecto.Query.t()
  def chat_with_users(user_ids) do
    user_ids_sum = Enum.sum(user_ids)

    from(c in Chat,
      join: cm in ChatMember,
      on: cm.chat_id == c.id,
      join: u in User,
      on: cm.user_id == u.id,
      where: u.id in ^user_ids,
      group_by: c.id,
      having: sum(u.id) == ^user_ids_sum,
      select: c
    )
  end

  @doc """
  Gets user's chats.
  """
  @spec user_chats(T.id()) :: Ecto.Query.t()
  def user_chats(user_id) do
    from(c in Chat,
      join: cm in ChatMember,
      on: cm.chat_id == c.id,
      join: u in User,
      on: cm.user_id == u.id,
      where: u.id == ^user_id,
      select: c
    )
  end

  @doc """
  Gets a certain user's chat.
  """
  @spec user_chat(T.id(), T.id()) :: Ecto.Query.t()
  def user_chat(user_id, chat_id) do
    user_chats(user_id)
    |> where([c], c.id == ^chat_id)
  end

  @doc """
  Gets chat members for specified user.
  """
  @spec user_chat_members(T.id()) :: Ecto.Query.t()
  def user_chat_members(user_id) do
    from(cm in ChatMember,
      join: u in User,
      on: u.id == cm.user_id,
      select: cm,
      where: u.id == ^user_id
    )
  end

  @doc """
  Gets messages the specified user can see.
  """
  @spec user_visible_messages(T.id()) :: Ecto.Query.t()
  def user_visible_messages(user_id) do
    from(m in Message,
      join: cm in ChatMember,
      on: cm.chat_id == m.chat_id,
      join: u in User,
      on: u.id == cm.user_id,
      select: m,
      where: u.id == ^user_id or m.user_id == ^user_id,
      group_by: m.id
    )
  end
end
