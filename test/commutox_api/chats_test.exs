defmodule CommutoxApi.ChatsTest do
  use CommutoxApi.DataCase

  import CommutoxApi.Fixtures

  alias CommutoxApi.Chats

  describe "chats" do
    alias CommutoxApi.Chats.Chat

    @valid_attrs %{}
    @update_attrs %{}

    test "list_chats/0 returns all chats" do
      {:ok, %{chat: chat}} = chat_fixture()

      format_chats = fn chats ->
        Enum.map(chats, &Map.drop(&1, [:users]))
      end

      chats = Chats.list_chats()

      assert format_chats.(chats) == format_chats.([chat])
    end

    test "get_chat!/1 returns the chat with given id" do
      {:ok, %{chat: chat}} = chat_fixture()

      chat = Map.drop(chat, [:users])
      fetched_chat = chat.id |> Chats.get_chat!() |> Map.drop([:users])

      assert fetched_chat == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      assert {:ok, %Chat{} = chat} = Chats.create_chat(@valid_attrs, [])
    end

    test "create_chat/1 with user ids creates a chat and associate users with chat" do
      {:ok, %{user: first_user}} = user_fixture()
      {:ok, %{user: second_user}} = user_fixture()

      {:ok, %Chat{} = chat} = Chats.create_chat(@valid_attrs, [first_user.id, second_user.id])

      chat_user_ids = chat |> Map.get(:users) |> Enum.map(&Map.get(&1, :id))

      assert chat_user_ids == [first_user.id, second_user.id]
    end

    test "create_chat/1 with user ids returns a chat when there is one" do
      {:ok, %{user: first_user}} = user_fixture()
      {:ok, %{user: second_user}} = user_fixture()

      {:ok, %Chat{} = first_chat} =
        Chats.create_chat(@valid_attrs, [first_user.id, second_user.id])

      {:ok, %Chat{} = second_chat} =
        Chats.create_chat(@valid_attrs, [first_user.id, second_user.id])

      assert first_chat.id == second_chat.id
    end

    test "update_chat/2 with valid data updates the chat" do
      {:ok, %{chat: chat}} = chat_fixture()
      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, @update_attrs)
    end

    test "delete_chat/1 deletes the chat" do
      {:ok, %{chat: chat}} = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      {:ok, %{chat: chat}} = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end

  describe "chat_members" do
    alias CommutoxApi.Chats.ChatMember

    @valid_scalar_attrs %{
      last_read_at: ~N[2019-12-01 21:32:00]
    }
    @update_scalar_attrs %{
      last_read_at: ~N[2019-12-02 22:34:20]
    }
    @invalid_scalar_attrs %{
      last_read_at: "invalid type"
    }

    def get_chat_member_valid_attrs do
      {:ok, %{user: user}} = user_fixture()
      {:ok, %{chat: chat}} = chat_fixture()

      Map.merge(@valid_scalar_attrs, %{user_id: user.id, chat_id: chat.id})
    end

    test "list_chat_members/0 returns all chat_members" do
      {:ok, %{chat_member: chat_member}} = chat_member_fixture()

      assert Chats.list_chat_members() == [chat_member]
    end

    test "get_chat_member!/1 returns the chat_member with given id" do
      {:ok, %{chat_member: chat_member}} = chat_member_fixture()

      assert Chats.get_chat_member!(chat_member.id) == chat_member
    end

    test "create_chat_member/1 with valid data creates a chat_member" do
      valid_attrs = get_chat_member_valid_attrs()

      assert {:ok, %ChatMember{} = chat_member} = Chats.create_chat_member(valid_attrs)
    end

    test "create_chat_member/1 with invalid data returns error changeset" do
      valid_attrs = get_chat_member_valid_attrs()

      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_member(%{valid_attrs | user_id: nil})

      assert {:error, %Ecto.Changeset{}} = Chats.create_chat_member(%{valid_attrs | chat_id: nil})

      assert {:error, %Ecto.Changeset{}} =
               Chats.create_chat_member(Map.merge(valid_attrs, @invalid_scalar_attrs))
    end

    test "update_chat_member/2 with valid data updates the chat_member" do
      {:ok, %{chat_member: chat_member}} = chat_member_fixture()

      assert {:ok, %ChatMember{} = chat_member} =
               Chats.update_chat_member(chat_member, @update_scalar_attrs)
    end

    test "update_chat_member/2 with invalid data returns error changeset" do
      {:ok, %{chat_member: chat_member}} = chat_member_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Chats.update_chat_member(chat_member, @invalid_scalar_attrs)

      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_member(chat_member, %{user_id: nil})
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat_member(chat_member, %{chat_id: nil})
      assert chat_member == Chats.get_chat_member!(chat_member.id)
    end

    test "delete_chat_member/1 deletes the chat_member" do
      {:ok, %{chat_member: chat_member}} = chat_member_fixture()
      assert {:ok, %ChatMember{}} = Chats.delete_chat_member(chat_member)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat_member!(chat_member.id) end
    end

    test "change_chat_member/1 returns a chat_member changeset" do
      {:ok, %{chat_member: chat_member}} = chat_member_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat_member(chat_member)
    end
  end

  describe "messages" do
    alias CommutoxApi.Chats.Message

    @valid_scalar_attrs %{
      text: "some text"
    }
    @update_scalar_attrs %{
      text: "some updated text"
    }
    @invalid_scalar_attrs %{
      text: 123
    }

    def get_message_valid_attrs do
      {:ok, %{user: user}} = user_fixture(%{email: "some_new@email"})
      {:ok, %{chat: chat}} = chat_fixture(%{}, [user.id])

      Map.merge(@valid_scalar_attrs, %{user_id: user.id, chat_id: chat.id})
    end

    test "list_messages/0 returns all messages" do
      {:ok, %{message: message}} = message_fixture()
      assert Chats.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      {:ok, %{message: message}} = message_fixture()
      assert Chats.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = get_message_valid_attrs()

      assert {:ok, %Message{} = message} = Chats.create_message(valid_attrs)
    end

    test "create_message/1 with invalid data returns error changeset" do
      valid_attrs = get_message_valid_attrs()

      assert {:error, %Ecto.Changeset{}} =
               Chats.create_message(Map.merge(valid_attrs, %{text: nil}))

      assert {:error, %Ecto.Changeset{}} =
               Chats.create_message(Map.merge(valid_attrs, %{text: 1}))

      assert {:error, %Ecto.Changeset{}} =
               Chats.create_message(Map.merge(valid_attrs, %{chat_id: nil}))

      assert {:error, %Ecto.Changeset{}} =
               Chats.create_message(Map.merge(valid_attrs, %{user_id: nil}))
    end

    test "create_message/1 with chat user isn't participating in returns error" do
      valid_attrs = get_message_valid_attrs()
      {:ok, %{chat: non_user_chat}} = chat_fixture()

      assert {:error, "User isn't in the chat."} =
               valid_attrs |> Map.merge(%{chat_id: non_user_chat.id}) |> Chats.create_message()
    end

    test "update_message/2 with valid data updates the message" do
      {:ok, %{message: message}} = message_fixture()

      valid_update_attrs = Map.merge(get_message_valid_attrs(), @update_scalar_attrs)

      assert {:ok, %Message{} = message} = Chats.update_message(message, valid_update_attrs)
    end

    test "update_message/2 with invalid data returns error changeset" do
      {:ok, %{message: message}} = message_fixture()

      assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, @invalid_scalar_attrs)
      assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, %{user_id: nil})
      assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, %{chat_id: nil})
      assert message == Chats.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      {:ok, %{message: message}} = message_fixture()
      assert {:ok, %Message{}} = Chats.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      {:ok, %{message: message}} = message_fixture()
      assert %Ecto.Changeset{} = Chats.change_message(message)
    end
  end
end
