defmodule CommutoxApiWeb.Graphql.Queries.MessagesTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApi.Fixtures
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApiWeb.GraphqlHelpers

  @messages_query """
    query Messages($first: Int) {
      messages(first: $first) {
        edges {
          node {
            id
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

    test "`messages` returns only messages from viewer's chats", %{conn: conn, user: viewer} do
      {:ok, %{user: participant}} = user_fixture()
      {:ok, %{chat: chat}} = chat_fixture(%{}, [viewer.id, participant.id])

      {:ok, %{message: viewer_message}} = message_fixture(%{chat_id: chat.id, user_id: viewer.id})

      {:ok, %{message: participant_message}} =
        message_fixture(%{chat_id: chat.id, user_id: participant.id})

      query_variables = %{first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @messages_query, variables: query_variables)

      expected_response = %{
        "data" => %{
          "messages" => %{
            "edges" => [
              %{"node" => %{"id" => to_global_id(:message, viewer_message.id)}},
              %{"node" => %{"id" => to_global_id(:message, participant_message.id)}}
            ]
          }
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end

  describe "when user isn't authorized" do
    test "`messages` returns error", %{conn: conn} do
      query_variables = %{first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @messages_query, variables: query_variables)

      expected_response = %{
        "data" => %{"messages" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHORIZED"},
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "You should be authorized.",
            "path" => ["messages"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end
end
