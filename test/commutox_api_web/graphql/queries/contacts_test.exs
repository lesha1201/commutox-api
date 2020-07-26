defmodule CommutoxApiWeb.Graphql.Queries.ContactsTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApi.Fixtures
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApiWeb.GraphqlHelpers

  @contacts_query """
    query Contacts($first: Int) {
      contacts(first: $first) {
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

      seed_contact_statuses()

      {:ok, Map.merge(context, %{conn: conn, user: user})}
    end

    test "`contacts` returns only viewer's contacts", %{conn: conn, user: user} do
      {:ok, %{user: user_A}} = user_fixture()
      {:ok, %{user: user_B}} = user_fixture()

      {:ok, %{contact: _non_viewer_contact_A}} =
        contact_fixture(:pending, %{user_sender_id: user_A.id, user_receiver_id: user_B.id})

      {:ok, %{contact: viewer_contact_A}} =
        contact_fixture(:pending, %{user_sender_id: user.id, user_receiver_id: user_A.id})

      {:ok, %{contact: viewer_contact_B}} =
        contact_fixture(:accepted, %{user_sender_id: user_B.id, user_receiver_id: user.id})

      query_variables = %{first: 100}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @contacts_query, variables: query_variables)

      expected_response = %{
        "data" => %{
          "contacts" => %{
            "edges" => [
              %{"node" => %{"id" => to_global_id(:contact, viewer_contact_A.id)}},
              %{"node" => %{"id" => to_global_id(:contact, viewer_contact_B.id)}}
            ]
          }
        }
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end

  describe "when user isn't authorized" do
    setup _context do
      seed_contact_statuses()
    end

    test "`contacts` returns error", %{conn: conn} do
      query_variables = %{first: 100}

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @contacts_query, variables: query_variables)

      expected_response = %{
        "data" => %{"contacts" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHENTICATED"},
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "You must be authenticated.",
            "path" => ["contacts"]
          }
        ]
      }

      assert Map.equal?(resp_decoded, expected_response)
    end
  end
end
