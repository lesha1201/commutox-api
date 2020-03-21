defmodule CommutoxApi.Chats.Chat.Query do
  @moduledoc """
  SQL queries related to Chat.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.{Chat, ChatMember}
  alias CommutoxUtils.Types, as: T

  @doc """
  Query that finds chat with certain users.
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
  Query that gets user's chats.
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
  Query that gets a certain user's chat.
  """
  @spec user_chat(T.id(), T.id()) :: Ecto.Query.t()
  def user_chat(user_id, chat_id) do
    user_chats(user_id)
    |> where([c], c.id == ^chat_id)
  end
end
