defmodule CommutoxApiWeb.Resolvers.Chat do
  import Ecto.Query, warn: false

  alias Absinthe.Relay.Connection
  alias CommutoxApi.{Repo}
  alias CommutoxApi.Accounts.{User}
  alias CommutoxApi.Chats.{Chat, ChatMember, Message}
  alias CommutoxApiWeb.Errors

  # Queries

  def list_chats(args, %{context: %{current_user: current_user}}) do
    from(c in Chat,
      join: cm in ChatMember,
      on: cm.chat_id == c.id,
      join: u in User,
      on: cm.user_id == u.id,
      select: c,
      where: u.id == ^current_user.id
    )
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_chats(_, _) do
    {:error, Errors.unauthorized()}
  end

  def list_chat_members(args, %{context: %{current_user: current_user}}) do
    from(cm in ChatMember,
      join: u in User,
      on: u.id == cm.user_id,
      select: cm,
      where: u.id == ^current_user.id
    )
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_chat_members(_, _) do
    {:error, Errors.unauthorized()}
  end

  def list_messages(args, %{context: %{current_user: current_user}}) do
    from(m in Message,
      join: cm in ChatMember,
      on: cm.chat_id == m.chat_id,
      join: u in User,
      on: u.id == cm.user_id,
      select: m,
      where: u.id == ^current_user.id or m.user_id == ^current_user.id,
      group_by: m.id
    )
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_messages(_, _) do
    {:error, Errors.unauthorized()}
  end
end
