defmodule CommutoxApiWeb.Graphql.Mutations.AddContactTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApi.Fixtures

  @add_contact_mutation """
  mutation AddContact($input: AddContactInput!) {
    addContact(input: $input) {
      contact {
        id
        user {
          email
        }
      }
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

    test "`addContact` returns contact when mutation is successfull", %{conn: conn} do
      {:ok, %{user: contact_user}} = user_fixture()
      contact_user_email = contact_user.email

      query_variables = %{
        input: %{
          user_email: contact_user_email
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @add_contact_mutation, variables: query_variables)

      assert %{
               "data" => %{
                 "addContact" => %{"contact" => %{"user" => %{"email" => ^contact_user_email}}}
               }
             } = resp_decoded
    end

    test "`addContact` returns error when contact_user is the current user", %{
      conn: conn,
      user: current_user
    } do
      contact_user_email = current_user.email

      query_variables = %{
        input: %{
          user_email: contact_user_email
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @add_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"addContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["Contact user can't be the current user."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["addContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`addContact` returns error when the current user already created such contact", %{
      conn: conn
    } do
      {:ok, %{user: contact_user}} = user_fixture()
      contact_user_email = contact_user.email

      query_variables = %{
        input: %{
          user_email: contact_user_email
        }
      }

      graphql_query(conn, query: @add_contact_mutation, variables: query_variables)

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @add_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"addContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["You already have such contact."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["addContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`addContact` returns error when arguments are invalid", %{conn: conn} do
      query_variables = %{
        input: %{}
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @add_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"addContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["You must provide either id or email of contact user."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["addContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end

  describe "when user isn't authorized" do
    test "`addContact` returns error", %{conn: conn} do
      query_variables = %{
        input: %{
          user_email: "email"
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @add_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"addContact" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHENTICATED"},
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "You must be authenticated.",
            "path" => ["addContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end
end
