defmodule CommutoxApi.Fixtures do
  alias CommutoxApi.{Accounts, Chats}

  # User

  def get_user_valid_attrs do
    uuid = generate_uuid()

    %{
      email: "user_#{uuid}@email",
      full_name: "Tom #{uuid}",
      password: "user_fixture password",
      password_confirmation: "user_fixture password"
    }
  end

  def user_fixture(attrs \\ %{}) do
    user_valid_attrs = get_user_valid_attrs()

    {:ok, user} =
      attrs
      |> Enum.into(user_valid_attrs)
      |> Accounts.create_user()

    {:ok, %{user: user}}
  end

  # Chat member

  @chat_member_valid_attrs %{
    last_read_at: ~N[2000-01-12 23:02:01]
  }

  def chat_member_fixture(%{user_id: _user_id, chat_id: _chat_id} = chat_member_attrs) do
    {:ok, chat_member} =
      @chat_member_valid_attrs
      |> Map.merge(chat_member_attrs)
      |> Chats.create_chat_member()

    {:ok, %{chat_member: chat_member}}
  end

  def chat_member_fixture(chat_member_attrs \\ %{}, b \\ %{}, c \\ %{})

  def chat_member_fixture(%{user_id: _user_id} = chat_member_attrs, chat_attrs, _) do
    {:ok, %{chat: chat}} = chat_fixture(chat_attrs)

    {:ok, %{chat_member: chat_member}} =
      chat_member_attrs
      |> Map.merge(%{chat_id: chat.id})
      |> chat_member_fixture()

    {:ok, %{chat_member: chat_member, chat: chat}}
  end

  def chat_member_fixture(%{chat_id: _chat_id} = chat_member_attrs, user_attrs, _) do
    {:ok, %{user: user}} = user_fixture(user_attrs)

    {:ok, %{chat_member: chat_member}} =
      chat_member_attrs
      |> Map.merge(%{user_id: user.id})
      |> chat_member_fixture()

    {:ok, %{chat_member: chat_member, user: user}}
  end

  def chat_member_fixture(chat_member_attrs, user_attrs, chat_attrs) do
    {:ok, %{user: user}} = user_fixture(user_attrs)
    {:ok, %{chat: chat}} = chat_fixture(chat_attrs)

    {:ok, %{chat_member: chat_member}} =
      chat_member_attrs
      |> Map.merge(%{user_id: user.id, chat_id: chat.id})
      |> chat_member_fixture()

    {:ok, %{chat_member: chat_member, user: user, chat: chat}}
  end

  # Chat

  @chat_valid_attrs %{}

  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(@chat_valid_attrs)
      |> Chats.create_chat()

    {:ok, %{chat: chat}}
  end

  # Message

  @message_valid_attrs %{
    text: "message_fixture text"
  }

  def message_fixture(%{user_id: _user_id, chat_id: _chat_id} = message_attrs) do
    {:ok, message} =
      @message_valid_attrs
      |> Map.merge(message_attrs)
      |> Chats.create_message()

    {:ok, %{message: message}}
  end

  def message_fixture(message_attrs \\ %{}, b \\ %{}, c \\ %{})

  def message_fixture(%{user_id: _user_id} = message_attrs, chat_attrs, _) do
    {:ok, %{chat: chat}} = chat_fixture(chat_attrs)

    {:ok, %{message: message}} =
      message_attrs
      |> Map.merge(%{chat_id: chat.id})
      |> message_fixture()

    {:ok, %{message: message, chat: chat}}
  end

  def message_fixture(%{chat_id: _chat_id} = message_attrs, user_attrs, _) do
    {:ok, %{user: user}} = user_fixture(user_attrs)

    {:ok, %{message: message}} =
      message_attrs
      |> Map.merge(%{user_id: user.id})
      |> message_fixture()

    {:ok, %{message: message, user: user}}
  end

  def message_fixture(message_attrs, user_attrs, chat_attrs) do
    {:ok, %{user: user}} = user_fixture(user_attrs)
    {:ok, %{chat: chat}} = chat_fixture(chat_attrs)

    {:ok, %{message: message}} =
      message_attrs
      |> Map.merge(%{user_id: user.id, chat_id: chat.id})
      |> message_fixture()

    {:ok, %{message: message, user: user, chat: chat}}
  end

  defp generate_uuid do
    Ecto.UUID.generate()
  end
end
