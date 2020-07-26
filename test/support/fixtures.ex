defmodule CommutoxApi.Fixtures do
  alias CommutoxApi.{Accounts, Chats, Contacts}

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
      |> Accounts.Store.create_user()

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
      |> Chats.Store.create_chat_member()

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

  def chat_fixture(attrs \\ %{}, user_ids \\ []) do
    {:ok, chat} =
      attrs
      |> Enum.into(@chat_valid_attrs)
      |> Chats.create_chat(user_ids)

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
      |> Chats.Store.create_message()

    {:ok, %{message: message}}
  end

  def message_fixture(message_attrs \\ %{}, b \\ %{}, c \\ %{})

  def message_fixture(%{user_id: user_id} = message_attrs, chat_attrs, _) do
    {:ok, %{chat: chat}} = chat_fixture(chat_attrs, [user_id])

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
    {:ok, %{chat: chat}} = chat_fixture(chat_attrs, [user.id])

    {:ok, %{message: message}} =
      message_attrs
      |> Map.merge(%{user_id: user.id, chat_id: chat.id})
      |> message_fixture()

    {:ok, %{message: message, user: user, chat: chat}}
  end

  # Contact status

  def contact_status_fixture(:pending) do
    {:ok, contact_status} = Contacts.Store.create_contact_status(Contacts.Constants.pending())

    {:ok, %{contact_status: contact_status}}
  end

  def contact_status_fixture(:accepted) do
    {:ok, contact_status} = Contacts.Store.create_contact_status(Contacts.Constants.accepted())

    {:ok, %{contact_status: contact_status}}
  end

  def contact_status_fixture(:rejected) do
    {:ok, contact_status} = Contacts.Store.create_contact_status(Contacts.Constants.rejected())

    {:ok, %{contact_status: contact_status}}
  end

  def seed_contact_statuses do
    {:ok, %{contact_status: _pending_contact_status}} = contact_status_fixture(:pending)
    {:ok, %{contact_status: _accepted_contact_status}} = contact_status_fixture(:accepted)
    {:ok, %{contact_status: _rejected_contact_status}} = contact_status_fixture(:rejected)

    :ok
  end

  # Contact

  def contact_fixture(type, contact_attrs \\ %{})

  def contact_fixture(:pending, contact_attrs) do
    pending_status = Contacts.Constants.pending()

    contact_attrs
    |> Map.merge(%{status_code: pending_status.code})
    |> contact_fixture()
  end

  def contact_fixture(:accepted, contact_attrs) do
    accepted_status = Contacts.Constants.accepted()

    contact_attrs
    |> Map.merge(%{status_code: accepted_status.code})
    |> contact_fixture()
  end

  def contact_fixture(:rejected, contact_attrs) do
    rejected_status = Contacts.Constants.rejected()

    contact_attrs
    |> Map.merge(%{status_code: rejected_status.code})
    |> contact_fixture()
  end

  def contact_fixture(contact_attrs, _) do
    {:ok, contact} = Contacts.Store.create_contact(contact_attrs)

    {:ok, %{contact: contact}}
  end

  def contact_fixture(type, user_sender_attrs, user_receiver_attrs) do
    {:ok, %{user: user_sender}} = user_fixture(user_sender_attrs)
    {:ok, %{user: user_receiver}} = user_fixture(user_receiver_attrs)

    {:ok, %{contact: contact}} =
      contact_fixture(type, %{user_sender_id: user_sender.id, user_receiver_id: user_receiver.id})

    {:ok, %{contact: contact, user_sender: user_sender, user_receiver: user_receiver}}
  end

  # Utils

  defp generate_uuid do
    Ecto.UUID.generate()
  end
end
