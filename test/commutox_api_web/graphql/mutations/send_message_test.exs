defmodule CommutoxApiWeb.Graphql.Mutations.SendMessageTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApi.Fixtures

  alias CommutoxApi.Chats
  alias CommutoxApi.Repo
  alias CommutoxApi.Chats.Message

  @send_message_mutation """
  mutation SendMessage($input: SendMessageInput!) {
    sendMessage(input: $input) {
      message {
        id
        text
      }
    }
  }
  """

  def authenticate_user(%{conn: conn} = context) do
    {:ok, %{user: user}} = user_fixture()
    conn = authenticate_with_jwt(conn, user)

    {:ok, Map.merge(context, %{conn: conn, user: user})}
  end

  describe "when user is authorized" do
    setup [:authenticate_user]

    test "`send_message` returns error if a message is blank", %{conn: conn} do
      {:ok, %{user: receiver}} = user_fixture()

      query_variables = %{
        input: %{
          text: "",
          to: to_global_id(:user, receiver.id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"sendMessage" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => %{"text" => ["can't be blank"]}
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["sendMessage"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end

  describe "when user is authorized and sends a message to a user" do
    setup [:authenticate_user]

    test "`send_message` returns error if user doesn't exist", %{conn: conn} do
      query_variables = %{
        input: %{
          text: "message text",
          to: to_global_id(:user, 123)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"sendMessage" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["Couldn't find a user with such id."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["sendMessage"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`send_message` creates a new chat if needed and sends a message", %{
      conn: conn,
      user: current_user
    } do
      {:ok, %{user: receiver}} = user_fixture()

      assert length(Chats.list_chats()) == 0

      query_variables = %{
        input: %{
          text: "message text",
          to: to_global_id(:user, receiver.id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      assert %{
               "data" => %{
                 "sendMessage" => %{
                   "message" => %{"id" => _id, "text" => "message text"} = resp_message
                 }
               }
             } = resp_decoded

      {:ok, %{id: resp_message_id}} = from_global_id(resp_message["id"])

      assert %Message{} = Chats.get_message(resp_message_id)

      chats = Chats.list_chats()
      chat = chats |> List.first() |> Repo.preload([:users])

      chat_user_ids = chat.users |> Enum.map(&Map.get(&1, :id)) |> Enum.sort()
      expected_chat_user_ids = Enum.sort([receiver.id, current_user.id])

      assert length(chats) == 1
      assert chat_user_ids == expected_chat_user_ids

      graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      assert %{
               "data" => %{
                 "sendMessage" => %{
                   "message" => %{"id" => _id, "text" => "message text"} = resp_message
                 }
               }
             } = resp_decoded

      {:ok, %{id: resp_message_id}} = from_global_id(resp_message["id"])

      assert %Message{} = Chats.get_message(resp_message_id)
      assert length(Chats.list_chats()) == 1
    end
  end

  describe "when user is authorized and sends a message to a channel" do
    setup [:authenticate_user]

    test "`send_message` returns error if chat doesn't exist", %{conn: conn} do
      query_variables = %{
        input: %{
          text: "message text",
          to: to_global_id(:chat, 123)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"sendMessage" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["Couldn't find a chat with such id."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["sendMessage"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`send_message` returns error if sending to non-participating chat", %{conn: conn} do
      {:ok, %{chat: chat}} = chat_fixture()

      query_variables = %{
        input: %{
          text: "message text",
          to: to_global_id(:chat, chat.id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"sendMessage" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 3, "line" => 2}],
            "path" => ["sendMessage"],
            "message" => "User isn't in the chat."
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`send_message` sends a message", %{conn: conn, user: current_user} do
      {:ok, %{chat: chat}} = chat_fixture(%{}, [current_user.id])

      query_variables = %{
        input: %{
          text: "message text",
          to: to_global_id(:chat, chat.id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      assert %{
               "data" => %{
                 "sendMessage" => %{
                   "message" => %{"id" => _id, "text" => "message text"} = resp_message
                 }
               }
             } = resp_decoded

      {:ok, %{id: resp_message_id}} = from_global_id(resp_message["id"])

      assert %Message{} = Chats.get_message(resp_message_id)
      assert length(Chats.list_chats()) == 1
    end
  end

  describe "when user isn't authorized" do
    test "`send_message` returns error", %{conn: conn} do
      {:ok, %{chat: chat}} = chat_fixture()

      query_variables = %{
        input: %{
          text: "message text",
          to: to_global_id(:chat, chat.id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @send_message_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"sendMessage" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHORIZED"},
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "You should be authorized.",
            "path" => ["sendMessage"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end
end
