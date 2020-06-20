defmodule CommutoxApi.Chats.ChatMember.Query do
  @moduledoc """
  SQL queries related to ChatMember.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Chats.ChatMember
  alias CommutoxUtils.Types, as: T

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
end
