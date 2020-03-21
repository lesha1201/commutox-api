defmodule CommutoxApiWeb.Resolvers.Chat do
  import Ecto.Query, warn: false

  alias Absinthe.Relay.{Connection, Node}
  alias CommutoxApi.{Repo}
  alias CommutoxApi.Accounts
  alias CommutoxApi.Accounts.{User}
  alias CommutoxApi.Chats
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

  # Mutations

  def send_message(
        %{to: to, text: text},
        %{
          context: %{current_user: _current_user},
          schema: schema
        } = resolution
      ) do
    case Node.from_global_id(to, schema) do
      {:ok, %{type: :user, id: user_id}} ->
        case send_message_to_user(%{user_id: user_id, text: text}, resolution) do
          {:ok, message} ->
            {:ok, %{message: message}}

          {:error, reason} ->
            {:error, reason}
        end

      {:ok, %{type: :chat, id: chat_id}} ->
        case send_message_to_chat(%{chat_id: chat_id, text: text}, resolution) do
          {:ok, message} ->
            {:ok, %{message: message}}

          {:error, reason} ->
            {:error, reason}
        end

      _ ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: ["`to` should be ID of User or Chat."]
           }
         })}
    end
  end

  def send_message(_, _) do
    {:error, Errors.unauthorized()}
  end

  defp send_message_to_chat(%{chat_id: chat_id, text: text}, %{
         context: %{current_user: current_user}
       }) do
    chat = Chats.get_chat(chat_id)

    if chat do
      Chats.create_message(%{user_id: current_user.id, chat_id: chat_id, text: text})
    else
      {:error,
       Errors.invalid_input(%{
         extensions: %{
           details: ["Couldn't find a chat with such id."]
         }
       })}
    end
  end

  defp send_message_to_user(%{user_id: user_id, text: text}, %{
         context: %{current_user: current_user}
       }) do
    user = Accounts.get_user(user_id)

    if user do
      case Chats.create_chat(%{}, [user.id, current_user.id]) do
        {:ok, chat} ->
          Chats.create_message(%{user_id: current_user.id, chat_id: chat.id, text: text})

        {:error, error} ->
          {:error, error}
      end
    else
      {:error,
       Errors.invalid_input(%{
         extensions: %{
           details: ["Couldn't find a user with such id."]
         }
       })}
    end
  end
end
