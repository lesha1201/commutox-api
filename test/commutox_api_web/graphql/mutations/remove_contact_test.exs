defmodule CommutoxApiWeb.Graphql.Mutations.RemoveContactTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApi.Fixtures

  @remove_contact_mutation """
  mutation RemoveContact($input: RemoveContactInput!) {
    removeContact(input: $input) {
      success
    }
  }
  """

  def authenticate_user(%{conn: conn} = context) do
    {:ok, %{user: user}} = user_fixture()
    conn = authenticate_with_jwt(conn, user)

    seed_contact_statuses()

    {:ok, Map.merge(context, %{conn: conn, user: user})}
  end

  describe "when user is authorized" do
    setup [:authenticate_user]

    test "`removeContact` returns success when the actor user is sender of the contact", %{
      conn: conn,
      user: current_user
    } do
      {:ok, %{user: contact_user}} = user_fixture()

      {:ok, %{contact: %{id: contact_id}}} =
        contact_fixture(:pending, %{
          user_sender_id: current_user.id,
          user_receiver_id: contact_user.id
        })

      query_variables = %{
        input: %{
          id: to_global_id(:contact, contact_id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @remove_contact_mutation, variables: query_variables)

      expected_response = %{"data" => %{"removeContact" => %{"success" => true}}}

      assert resp_decoded == expected_response
    end

    test "`removeContact` returns error if the contact doesn't exist", %{conn: conn} do
      non_existing_contact_id = "Q29udGFjdDoz"

      query_variables = %{
        input: %{
          id: non_existing_contact_id
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @remove_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"removeContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["Couldn't find such contact."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["removeContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`removeContact` returns error if the contact doesn't belong to the current user", %{
      conn: conn
    } do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})

      query_variables = %{
        input: %{
          id: to_global_id(:contact, contact.id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @remove_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"removeContact" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["removeContact"],
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["Contact doesn't belong to you."]
            }
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`removeContact` returns error if the contact is pending/rejected incoming request", %{
      conn: conn,
      user: current_user
    } do
      {:ok, %{user: contact_user}} = user_fixture()

      {:ok, %{contact: contact}} =
        contact_fixture(:pending, %{
          user_sender_id: contact_user.id,
          user_receiver_id: current_user.id
        })

      query_variables = %{
        input: %{
          id: to_global_id(:contact, contact.id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @remove_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"removeContact" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["removeContact"],
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["You can't remove pending or rejected incoming requests."]
            }
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end

  describe "when user isn't authorized" do
    test "`removeContact` returns error", %{conn: conn} do
      query_variables = %{
        input: %{
          id: "Q29udGFjdDoz"
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @remove_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"removeContact" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHENTICATED"},
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "You must be authenticated.",
            "path" => ["removeContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end
end
