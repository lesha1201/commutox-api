defmodule CommutoxApiWeb.Graphql.Queries.NodeTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.ConnHelpers
  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApi.Fixtures

  setup %{conn: conn} = context do
    {:ok, %{user: user}} = user_fixture()
    conn = authenticate_with_jwt(conn, user)

    {:ok, Map.merge(context, %{conn: conn, user: user})}
  end

  test "User implements Node", %{conn: conn, user: user} do
    query = """
      query Node($id: ID!) {
        node(id: $id) {
          ... on User {
            id
          }
        }
      }
    """

    user = user |> to_response_format(:user, [:id])

    query_variables = %{id: user["id"]}

    expected_response = %{
      "data" => %{
        "node" => user
      }
    }

    %{resp_decoded: resp_decoded} =
      conn |> graphql_query(query: query, variables: query_variables)

    assert Map.equal?(resp_decoded, expected_response)
  end

  test "Chat implements Node", %{conn: conn, user: user} do
    query = """
      query Node($id: ID!) {
        node(id: $id) {
          ... on Chat {
            id
          }
        }
      }
    """

    chat =
      chat_member_fixture(%{user_id: user.id})
      |> (fn {:ok, %{chat: chat}} -> chat end).()
      |> to_response_format(:chat, [:id])

    query_variables = %{id: chat["id"]}

    expected_response = %{
      "data" => %{
        "node" => chat
      }
    }

    %{resp_decoded: resp_decoded} =
      conn |> graphql_query(query: query, variables: query_variables)

    assert Map.equal?(resp_decoded, expected_response)
  end

  test "ChatMember implements Node", %{conn: conn, user: user} do
    query = """
      query Node($id: ID!) {
        node(id: $id) {
          ... on ChatMember {
            id
          }
        }
      }
    """

    chat_member =
      chat_member_fixture(%{user_id: user.id})
      |> (fn {:ok, %{chat_member: chat_member}} -> chat_member end).()
      |> to_response_format(:chat_member, [:id])

    query_variables = %{id: chat_member["id"]}

    expected_response = %{
      "data" => %{
        "node" => chat_member
      }
    }

    %{resp_decoded: resp_decoded} =
      conn |> graphql_query(query: query, variables: query_variables)

    assert Map.equal?(resp_decoded, expected_response)
  end

  test "Message implements Node", %{conn: conn, user: user} do
    query = """
      query Node($id: ID!) {
        node(id: $id) {
          ... on Message {
            id
          }
        }
      }
    """

    {:ok, %{chat: viewer_chat}} = chat_member_fixture(%{user_id: user.id})

    message =
      message_fixture(%{user_id: user.id, chat_id: viewer_chat.id})
      |> (fn {:ok, %{message: message}} -> message end).()
      |> to_response_format(:message, [:id])

    query_variables = %{id: message["id"]}

    expected_response = %{
      "data" => %{
        "node" => message
      }
    }

    %{resp_decoded: resp_decoded} =
      conn |> graphql_query(query: query, variables: query_variables)

    assert Map.equal?(resp_decoded, expected_response)
  end
end
