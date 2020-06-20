defmodule CommutoxApiWeb.Resolvers.Chat do
  import Ecto.Query, warn: false

  alias Absinthe.Relay.{Connection, Node}
  alias CommutoxApi.{Repo}
  alias CommutoxApi.Accounts
  alias CommutoxApi.Chats
  alias CommutoxApi.Chats.{Chat, ChatMember, Message}
  alias CommutoxApiWeb.Errors

  # Queries

  def list_chats(args, %{context: %{current_user: current_user}}) do
    Chat.Query.user_chats(current_user.id)
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_chats(_, _) do
    {:error, Errors.unauthorized()}
  end

  def list_chat_members(args, %{context: %{current_user: current_user}}) do
    ChatMember.Query.user_chat_members(current_user.id)
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_chat_members(_, _) do
    {:error, Errors.unauthorized()}
  end

  def list_messages(args, %{context: %{current_user: current_user}}) do
    Message.Query.user_visible_messages(current_user.id)
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
