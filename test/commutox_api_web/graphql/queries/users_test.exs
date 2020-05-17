defmodule CommutoxApiWeb.Graphql.Queries.UsersTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApi.Fixtures

  @users_query """
    query Users($first: Int) {
      users(first: $first) {
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

    test "`users` returns all users", %{conn: conn, user: user} do
      query_variables = %{first: 2}

      %{"id" => user_global_id} = to_response_format(user, :user, [:id])

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @users_query, variables: query_variables)

      expected_response = %{
        "data" => %{
          "users" => %{"edges" => [%{"node" => %{"id" => user_global_id}}]}
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end

  describe "when user isn't authorized" do
    test "`users` returns error", %{conn: conn} do
      query_variables = %{first: 2}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @users_query, variables: query_variables)

      expected_response = %{
        "data" => %{"users" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHORIZED"},
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "You should be authorized.",
            "path" => ["users"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end
end
