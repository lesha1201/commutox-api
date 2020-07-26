defmodule CommutoxApiWeb.Resolvers.Chat do
  import Ecto.Query, warn: false

  alias Absinthe.Relay.{Node}
  alias CommutoxApi.Chats
  alias CommutoxApiWeb.Errors

  # Queries

  def list_chats(args, %{context: %{current_user: current_user}}) do
    case Chats.list_user_chats(current_user, args) do
      {:ok, result} ->
        {:ok, result}

      {:error, relay_error} ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{details: relay_error}
         })}
    end
  end

  def list_chats(_, _) do
    {:error, Errors.unauthenticated()}
  end

  def list_chat_members(args, %{context: %{current_user: current_user}}) do
    case Chats.list_user_chat_members(current_user, args) do
      {:ok, result} ->
        {:ok, result}

      {:error, relay_error} ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{details: relay_error}
         })}
    end
  end

  def list_chat_members(_, _) do
    {:error, Errors.unauthenticated()}
  end

  def list_messages(args, %{context: %{current_user: current_user}}) do
    case Chats.list_user_messages(current_user, args) do
      {:ok, result} ->
        {:ok, result}

      {:error, relay_error} ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{details: relay_error}
         })}
    end
  end

  def list_messages(_, _) do
    {:error, Errors.unauthenticated()}
  end

  # Mutations

  def send_message(
        %{to: to, text: text},
        %{
          context: %{current_user: current_user},
          schema: schema
        }
      ) do
    message_attrs = %{user_id: current_user.id, text: text}

    case Node.from_global_id(to, schema) do
      {:ok, %{type: :user, id: user_id}} ->
        send_message_to_user(%{id: String.to_integer(user_id)}, message_attrs)

      {:ok, %{type: :chat, id: chat_id}} ->
        Map.merge(message_attrs, %{chat_id: String.to_integer(chat_id)})
        |> send_message_to_chat()

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
    {:error, Errors.unauthenticated()}
  end

  @send_message_input_errors [:user_not_in_chat, :chat_not_found, :user_not_found]

  @send_message_errors %{
    user_not_in_chat: "User isn't in the chat.",
    chat_not_found: "Couldn't find such chat.",
    user_not_found: "Couldn't find such user."
  }

  defp send_message_to_user(user, message) do
    case Chats.send_message_to_user(user, message) do
      {:ok, message} ->
        {:ok, %{message: message}}

      {:error, error} when error in @send_message_input_errors ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: [transform_domain_error(:send_message, error)]
           }
         })}

      {:error, :receiver_user_not_found} ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: ["Couldn't find a receiver user with such id."]
           }
         })}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, _} ->
        {:error, Errors.internal_error()}
    end
  end

  defp send_message_to_chat(message) do
    case Chats.send_message(message) do
      {:ok, message} ->
        {:ok, %{message: message}}

      {:error, error} when error in @send_message_input_errors ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: [transform_domain_error(:send_message, error)]
           }
         })}

      {:error, _} ->
        {:error, Errors.internal_error()}
    end
  end

  # Utils

  defp transform_domain_error(:send_message, error_type) do
    Map.get(@send_message_errors, error_type)
  end
end
