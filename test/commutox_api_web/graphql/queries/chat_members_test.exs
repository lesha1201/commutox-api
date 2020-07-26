defmodule CommutoxApiWeb.Graphql.Queries.ChatMembersTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApi.Fixtures
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApiWeb.GraphqlHelpers

  @chat_members_query """
    query ChatMembers($first: Int) {
      chatMembers(first: $first) {
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

    test "`chatMembers` returns only viewer's chat members", %{conn: conn, user: viewer} do
      {:ok, %{chat: chat}} = chat_fixture()

      {:ok, %{chat_member: viewer_chat_member}} =
        chat_member_fixture(%{user_id: viewer.id, chat_id: chat.id})

      {:ok, %{chat_member: _participant_chat_member}} = chat_member_fixture(%{chat_id: chat.id})

      query_variables = %{first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @chat_members_query, variables: query_variables)

      expected_response = %{
        "data" => %{
          "chatMembers" => %{
            "edges" => [%{"node" => %{"id" => to_global_id(:chat_member, viewer_chat_member.id)}}]
          }
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end

  describe "when user isn't authorized" do
    test "`chatMembers` returns error", %{conn: conn} do
      query_variables = %{first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @chat_members_query, variables: query_variables)

      expected_response = %{
        "data" => %{"chatMembers" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHENTICATED"},
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "You must be authenticated.",
            "path" => ["chatMembers"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end
end
