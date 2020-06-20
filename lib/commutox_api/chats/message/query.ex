defmodule CommutoxApi.Chats.Message.Query do
  @moduledoc """
  SQL queries related to Message.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.{ChatMember, Message}
  alias CommutoxUtils.Types, as: T

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
