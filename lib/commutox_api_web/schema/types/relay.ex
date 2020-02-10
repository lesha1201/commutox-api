defmodule CommutoxApiWeb.Schema.Types.Relay do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias CommutoxApi.{Accounts, Chats, Repo}
  alias CommutoxApiWeb.Errors

  object :relay_queries do
    node field do
      resolve(fn
        # User

        %{type: :user, id: id}, %{context: %{current_user: _current_user}} ->
          {:ok, Accounts.get_user(id)}

        %{type: :user, id: _id}, _ ->
          {:error, Errors.unauthorized()}

        # Chat member

        %{type: :chat_member, id: id}, %{context: %{current_user: current_user}} ->
          chat_member = Chats.get_chat_member(id) |> Repo.preload(chat: [:users])
          chat_users = chat_member.chat.users || []

          if Enum.any?(chat_users, fn user -> user.id == current_user.id end) do
            {:ok, chat_member}
          else
            {:error, Errors.forbidden(%{message: "You can't view this chat member."})}
          end

        %{type: :chat_member, id: _id}, _ ->
          {:error, Errors.unauthorized()}

        # Chat

        %{type: :chat, id: id}, %{context: %{current_user: current_user}} ->
          chat = Chats.get_chat(id) |> Repo.preload([:users])
          chat_users = chat.users || []

          if Enum.any?(chat_users, fn user -> user.id == current_user.id end) do
            {:ok, chat}
          else
            {:error, Errors.forbidden(%{message: "You can't view this chat."})}
          end

        %{type: :chat, id: _id}, _ ->
          {:error, Errors.unauthorized()}

        # Message

        %{type: :message, id: id}, %{context: %{current_user: current_user}} ->
          message = Chats.get_message(id) |> Repo.preload(chat: [:users])
          chat_users = message.chat.users || []

          if Enum.any?(chat_users, fn user -> user.id == current_user.id end) do
            {:ok, message}
          else
            {:error, Errors.forbidden(%{message: "You can't view this message."})}
          end

        %{type: :message, id: _id}, _ ->
          {:error, Errors.unauthorized()}

        # Invalid

        _, _ ->
          {:error, "Invalid ID supplied."}
      end)
    end
  end

  node interface do
    resolve_type(fn
      %Accounts.User{}, _ ->
        :user

      %Chats.ChatMember{}, _ ->
        :chat_member

      %Chats.Chat{}, _ ->
        :chat

      %Chats.Message{}, _ ->
        :message

      _, _ ->
        nil
    end)
  end
end
