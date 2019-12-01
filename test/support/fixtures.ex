defmodule CommutoxApi.Fixtures do
  alias CommutoxApi.{Accounts, Chats}

  @user_valid_attrs %{
    email: "some@email",
    full_name: "some full_name",
    password: "some password",
    password_confirmation: "some password"
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_valid_attrs)
      |> Accounts.create_user()

    user
  end

  @chat_member_valid_attrs %{
    last_read_at: ~N[2000-01-12 23:02:01]
  }

  def chat_member_fixture(attrs \\ %{}) do
    user = user_fixture()
    chat = chat_fixture()

    valid_attrs_with_relations =
      Map.merge(@chat_member_valid_attrs, %{user_id: user.id, chat_id: chat.id})

    {:ok, chat_member} =
      attrs
      |> Enum.into(valid_attrs_with_relations)
      |> Chats.create_chat_member()

    chat_member
  end

  @chat_valid_attrs %{}

  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(@chat_valid_attrs)
      |> Chats.create_chat()

    chat
  end

  @message_valid_attrs %{
    text: "some text"
  }

  def message_fixture(attrs \\ %{}) do
    user = user_fixture()
    chat = chat_fixture()

    valid_attrs_with_relations =
      Map.merge(@message_valid_attrs, %{user_id: user.id, chat_id: chat.id})

    {:ok, message} =
      attrs
      |> Enum.into(valid_attrs_with_relations)
      |> Chats.create_message()

    message
  end
end
