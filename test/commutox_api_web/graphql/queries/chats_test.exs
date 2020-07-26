defmodule CommutoxApiWeb.Graphql.Queries.ChatsTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApi.Fixtures

  @chats_query """
    query Chats($first: Int) {
      chats(first: $first) {
        edges {
          node {
            id
          }
        }
      }
    }
  """

  @chats_messages_query """
    query ChatsMessages($chatsFirst: Int, $messagesFirst: Int) {
      chats(first: $chatsFirst) {
        edges {
          node {
            id
            messages(first: $messagesFirst) {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
      }
    }
  """

  @chats_users_query """
    query ChatsUsers($chatsFirst: Int, $usersFirst: Int) {
      chats(first: $chatsFirst) {
        edges {
          node {
            id
            users(first: $usersFirst) {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
      }
    }
  """

  @chats_chat_members_query """
    query ChatsChatMembers($chatsFirst: Int, $chatMembersFirst: Int) {
      chats(first: $chatsFirst) {
        edges {
          node {
            id
            members(first: $chatMembersFirst) {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
      }
    }
  """

  describe "when user is authorized" do
    setup %{conn: conn} = context do
      {:ok, %{user: user}} = user_fixture()
      conn = authenticate_with_jwt(conn, user)

      {:ok, Map.merge(context, %{conn: conn, user: user})}
    end

    test "`chats` returns only viewer's chats", %{conn: conn, user: viewer} do
      {:ok, %{chat: _non_viewer_chat}} = chat_member_fixture()
      {:ok, %{chat: viewer_chat}} = chat_member_fixture(%{user_id: viewer.id})

      query_variables = %{first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @chats_query, variables: query_variables)

      %{"id" => viewer_chat_global_id} = to_response_format(viewer_chat, :chat, [:id])

      expected_response = %{
        "data" => %{
          "chats" => %{"edges" => [%{"node" => %{"id" => viewer_chat_global_id}}]}
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "quering messages on `chats` returns all chat's messages", %{conn: conn, user: viewer} do
      {:ok, %{user: participant}} = user_fixture()
      {:ok, %{chat: viewer_chat}} = chat_fixture(%{}, [viewer.id, participant.id])

      {:ok, %{message: viewer_message}} =
        message_fixture(%{user_id: viewer.id, chat_id: viewer_chat.id})

      {:ok, %{message: participant_message}} =
        message_fixture(%{chat_id: viewer_chat.id, user_id: participant.id})

      query_variables = %{chats_first: 2, messages_first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @chats_messages_query, variables: query_variables)

      %{"id" => viewer_chat_global_id} = to_response_format(viewer_chat, :chat, [:id])
      %{"id" => viewer_message_global_id} = to_response_format(viewer_message, :message, [:id])

      %{"id" => participant_message_global_id} =
        to_response_format(participant_message, :message, [:id])

      expected_response = %{
        "data" => %{
          "chats" => %{
            "edges" => [
              %{
                "node" => %{
                  "id" => viewer_chat_global_id,
                  "messages" => %{
                    "edges" => [
                      %{"node" => %{"id" => viewer_message_global_id}},
                      %{"node" => %{"id" => participant_message_global_id}}
                    ]
                  }
                }
              }
            ]
          }
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "quering users on `chats` returns all chat's users", %{conn: conn, user: viewer} do
      {:ok, %{chat: viewer_chat}} = chat_member_fixture(%{user_id: viewer.id})
      {:ok, %{user: chat_participant_user}} = chat_member_fixture(%{chat_id: viewer_chat.id})

      query_variables = %{chats_first: 2, users_first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @chats_users_query, variables: query_variables)

      %{"id" => viewer_chat_global_id} = to_response_format(viewer_chat, :chat, [:id])
      %{"id" => viewer_global_id} = to_response_format(viewer, :user, [:id])

      %{"id" => chat_participant_user_global_id} =
        to_response_format(chat_participant_user, :user, [:id])

      expected_response = %{
        "data" => %{
          "chats" => %{
            "edges" => [
              %{
                "node" => %{
                  "id" => viewer_chat_global_id,
                  "users" => %{
                    "edges" => [
                      %{"node" => %{"id" => viewer_global_id}},
                      %{"node" => %{"id" => chat_participant_user_global_id}}
                    ]
                  }
                }
              }
            ]
          }
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "quering members on `chats` returns all chat's members", %{conn: conn, user: viewer} do
      {:ok, %{chat: viewer_chat, chat_member: viewer_chat_member}} =
        chat_member_fixture(%{user_id: viewer.id})

      {:ok, %{chat_member: participant_chat_member}} =
        chat_member_fixture(%{chat_id: viewer_chat.id})

      query_variables = %{chats_first: 2, chat_members_first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @chats_chat_members_query, variables: query_variables)

      %{"id" => viewer_chat_global_id} = to_response_format(viewer_chat, :chat, [:id])

      %{"id" => viewer_chat_member_global_id} =
        to_response_format(viewer_chat_member, :chat_member, [:id])

      %{"id" => participant_chat_member_global_id} =
        to_response_format(participant_chat_member, :chat_member, [:id])

      expected_response = %{
        "data" => %{
          "chats" => %{
            "edges" => [
              %{
                "node" => %{
                  "id" => viewer_chat_global_id,
                  "members" => %{
                    "edges" => [
                      %{"node" => %{"id" => viewer_chat_member_global_id}},
                      %{"node" => %{"id" => participant_chat_member_global_id}}
                    ]
                  }
                }
              }
            ]
          }
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end

  describe "when user isn't authorized" do
    test "`chats` returns error", %{conn: conn} do
      query_variables = %{first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @chats_query, variables: query_variables)

      expected_response = %{
        "data" => %{"chats" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "You must be authenticated.",
            "extensions" => %{"code" => "UNAUTHENTICATED"},
            "path" => ["chats"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end
end
