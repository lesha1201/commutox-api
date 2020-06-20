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

  describe "Contact" do
    setup _context do
      seed_contact_statuses()
    end

    @contact_query """
      query Node($id: ID!) {
        node(id: $id) {
          ... on Contact {
            id
          }
        }
      }
    """

    test "it implements Node", %{conn: conn, user: user} do
      {:ok, %{user: user_receiver}} = user_fixture()

      contact =
        contact_fixture(:pending, %{user_sender_id: user.id, user_receiver_id: user_receiver.id})
        |> (fn {:ok, %{contact: contact}} -> contact end).()
        |> to_response_format(:contact, [:id])

      query_variables = %{id: contact["id"]}

      expected_response = %{
        "data" => %{
          "node" => contact
        }
      }

      %{resp_decoded: resp_decoded} =
        conn |> graphql_query(query: @contact_query, variables: query_variables)

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "user should be able to query only its contacts", %{conn: conn} do
      {:ok, %{contact: contact}} = contact_fixture(:accepted, %{}, %{})

      contact_global_id = to_global_id(:contact, contact.id)

      query_variables = %{
        id: contact_global_id
      }

      %{resp_decoded: resp_decoded} =
        conn
        |> graphql_query(query: @contact_query, variables: query_variables)

      expected_response = %{
        "data" => %{"node" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "FORBIDDEN"},
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "You can't view this contact.",
            "path" => ["node"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end
end
