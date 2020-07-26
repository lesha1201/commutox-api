defmodule CommutoxApiWeb.Graphql.Queries.UserTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApi.Fixtures

  @user_query """
    query User($email: String!) {
      user(email: $email) {
        id
        email
        fullName
      }
    }
  """

  @user_chats_query """
    query UserChats($email: String!, $chatsFirst: Int) {
      user(email: $email) {
        id
        chats(first: $chatsFirst) {
          edges {
            node {
              id
            }
          }
        }
      }
    }
  """

  @user_chat_members_query """
    query UserChatMembers($email: String!, $chatMembersFirst: Int) {
      user(email: $email) {
        id
        chatMembers(first: $chatMembersFirst) {
          edges {
            node {
              id
            }
          }
        }
      }
    }
  """

  @user_messages_query """
    query UserMessages($email: String!, $messagesFirst: Int) {
      user(email: $email) {
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
  """

  describe "when user is authorized" do
    setup %{conn: conn} = context do
      {:ok, %{user: user}} = user_fixture()
      conn = authenticate_with_jwt(conn, user)

      {:ok, Map.merge(context, %{conn: conn, user: user})}
    end

    test "`user` returns user by email", %{conn: conn} do
      query_variables = %{email: "test@test.com"}

      user =
        user_fixture(query_variables)
        |> (fn {:ok, %{user: user}} -> user end).()
        |> to_response_format(:user, [:email, :full_name, :id])

      expected_response = %{
        "data" => %{
          "user" => user
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_query, variables: query_variables)

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "`user` returns nil for non-existing user", %{conn: conn} do
      expected_response = %{
        "data" => %{
          "user" => nil
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_query, variables: %{email: "non_existing@test.com"})

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "quering chats on `user` returns it for viewer's user", %{conn: conn, user: user} do
      query_variables = %{email: user.email, chats_first: 2}

      chat_member_fixture(%{user_id: user.id})

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_chats_query, variables: query_variables)

      chats = get_in(resp_decoded, ["data", "user", "chats", "edges"])

      assert length(chats) > 0
    end

    test "quering chats on `user` returns error for non-viewer's user", %{conn: conn} do
      user =
        user_fixture(%{email: "new_user@test.com"})
        |> (fn {:ok, %{user: user}} -> user end).()
        |> to_response_format(:user, [:email, :full_name, :id])

      query_variables = %{email: user["email"], chats_first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_chats_query, variables: query_variables)

      expected_response = %{
        "data" => %{
          "user" => %{
            "chats" => nil,
            "id" => user["id"]
          }
        },
        "errors" => [
          %{
            "extensions" => %{"code" => "FORBIDDEN"},
            "locations" => [%{"column" => 7, "line" => 4}],
            "message" => "User chats are only available for the authenticated user.",
            "path" => ["user", "chats"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "quering chatMembers on `user` returns it for viewer's user", %{conn: conn, user: user} do
      query_variables = %{email: user.email, chat_members_first: 2}

      chat_member_fixture(%{user_id: user.id})

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_chat_members_query, variables: query_variables)

      chats = get_in(resp_decoded, ["data", "user", "chatMembers", "edges"])

      assert length(chats) > 0
    end

    test "quering chatMembers on `user` returns error for non-viewer's user", %{conn: conn} do
      user =
        user_fixture(%{email: "new_user@test.com"})
        |> (fn {:ok, %{user: user}} -> user end).()
        |> to_response_format(:user, [:email, :full_name, :id])

      query_variables = %{email: user["email"], chat_members_first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_chat_members_query, variables: query_variables)

      expected_response = %{
        "data" => %{
          "user" => %{
            "chatMembers" => nil,
            "id" => user["id"]
          }
        },
        "errors" => [
          %{
            "extensions" => %{"code" => "FORBIDDEN"},
            "locations" => [%{"column" => 7, "line" => 4}],
            "message" => "User chat members are only available for the authenticated user.",
            "path" => ["user", "chatMembers"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "quering messages on `user` returns it for viewer's user", %{conn: conn, user: user} do
      query_variables = %{email: user.email, messages_first: 2}

      message_fixture(%{user_id: user.id})

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_messages_query, variables: query_variables)

      chats = get_in(resp_decoded, ["data", "user", "messages", "edges"])

      assert length(chats) > 0
    end

    test "quering messages on `user` returns error for non-viewer's user", %{conn: conn} do
      user =
        user_fixture(%{email: "new_user@test.com"})
        |> (fn {:ok, %{user: user}} -> user end).()
        |> to_response_format(:user, [:email, :full_name, :id])

      query_variables = %{email: user["email"], messages_first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_messages_query, variables: query_variables)

      expected_response = %{
        "data" => %{
          "user" => %{
            "messages" => nil,
            "id" => user["id"]
          }
        },
        "errors" => [
          %{
            "extensions" => %{"code" => "FORBIDDEN"},
            "locations" => [%{"column" => 7, "line" => 4}],
            "message" => "User messages are only available for the authenticated user.",
            "path" => ["user", "messages"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end

  describe "when user isn't authorized" do
    test "`user` returns error", %{conn: conn} do
      query_variables = %{email: "test@test.com"}

      user_fixture(query_variables)

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @user_query, variables: query_variables)

      expected_response = %{
        "data" => %{"user" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHENTICATED"},
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "You must be authenticated.",
            "path" => ["user"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end
end
