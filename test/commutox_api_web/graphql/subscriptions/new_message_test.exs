defmodule CommutoxApiWeb.Graphql.Subscriptions.NewMessageTest do
  use CommutoxApiWeb.ChannelCase

  import CommutoxApi.Fixtures
  import CommutoxApiWeb.GraphqlHelpers

  alias CommutoxApi.Chats

  @new_message_subscription """
    subscription NewMessage {
      newMessage {
        id
      }
    }
  """

  setup do
    {:ok, %{user: user}} = user_fixture()
    {:ok, %{user: participant_user}} = user_fixture()

    {:ok, %{chat: chat}} = chat_fixture(%{}, [user.id, participant_user.id])

    {:ok, socket} =
      connect_to_socket(user)
      |> join_absinthe()

    {:ok, %{socket: socket, current_user: user, chat: chat, participant_user: participant_user}}
  end

  test "current user should receive message from the other user", %{
    socket: socket,
    participant_user: participant_user,
    chat: chat
  } do
    ref = push_doc(socket, @new_message_subscription)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    {:ok, message} =
      Chats.send_message(%{user_id: participant_user.id, chat_id: chat.id, text: "Hello, User!"})

    expected_payload = %{
      result: %{data: %{"newMessage" => %{"id" => to_global_id(:message, message.id)}}},
      subscriptionId: subscription_id
    }

    assert_push("subscription:data", ^expected_payload)
  end

  test "current user should receive message from itself", %{
    socket: socket,
    current_user: current_user,
    chat: chat
  } do
    ref = push_doc(socket, @new_message_subscription)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    {:ok, message} =
      Chats.send_message(%{
        user_id: current_user.id,
        chat_id: chat.id,
        text: "Hello, Participant!"
      })

    expected_payload = %{
      result: %{data: %{"newMessage" => %{"id" => to_global_id(:message, message.id)}}},
      subscriptionId: subscription_id
    }

    assert_push("subscription:data", ^expected_payload)
  end

  test "current user shouldn't receive message from the chat it's not participating in", %{
    socket: socket
  } do
    ref = push_doc(socket, @new_message_subscription)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    {:ok, %{user: user_a}} = user_fixture()
    {:ok, %{user: user_b}} = user_fixture()

    {:ok, %{chat: other_chat}} = chat_fixture(%{}, [user_a.id, user_b.id])

    {:ok, message} =
      Chats.send_message(%{
        user_id: user_a.id,
        chat_id: other_chat.id,
        text: "Hello!"
      })

    expected_payload = %{
      result: %{data: %{"newMessage" => %{"id" => to_global_id(:message, message.id)}}},
      subscriptionId: subscription_id
    }

    refute_push("subscription:data", ^expected_payload)
  end

  test "works with several subscriptions", %{
    socket: socket,
    participant_user: participant_user,
    chat: chat
  } do
    ref = push_doc(socket, @new_message_subscription)
    assert_reply(ref, :ok, %{subscriptionId: current_user_subscription_id})

    {:ok, participant_socket} = connect_to_socket(participant_user) |> join_absinthe()

    ref = push_doc(participant_socket, @new_message_subscription)
    assert_reply(ref, :ok, %{subscriptionId: participant_subscription_id})

    {:ok, message} =
      Chats.send_message(%{
        user_id: participant_user.id,
        chat_id: chat.id,
        text: "Hello!"
      })

    message_global_id = to_global_id(:message, message.id)

    expected_payload = %{
      result: %{data: %{"newMessage" => %{"id" => message_global_id}}},
      subscriptionId: current_user_subscription_id
    }

    assert_push("subscription:data", ^expected_payload)

    expected_payload = %{
      result: %{data: %{"newMessage" => %{"id" => message_global_id}}},
      subscriptionId: participant_subscription_id
    }

    assert_push("subscription:data", ^expected_payload)
  end
end
