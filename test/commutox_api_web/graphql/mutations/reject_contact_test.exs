defmodule CommutoxApiWeb.Graphql.Mutations.RejectContactTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApiWeb.ConnHelpers
  import CommutoxApi.Fixtures

  @reject_contact_mutation """
  mutation RejectContact($input: RejectContactInput!) {
    rejectContact(input: $input) {
      contact {
        id
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

    test "`rejectContact` returns a contact when mutation is successful", %{
      conn: conn,
      user: current_user
    } do
      {:ok, %{user: contact_user}} = user_fixture()

      {:ok, %{contact: %{id: contact_id}}} =
        contact_fixture(:pending, %{
          user_sender_id: contact_user.id,
          user_receiver_id: current_user.id
        })

      contact_global_id = to_global_id(:contact, contact_id)

      query_variables = %{
        input: %{
          id: contact_global_id
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @reject_contact_mutation, variables: query_variables)

      assert %{
               "data" => %{
                 "rejectContact" => %{"contact" => %{"id" => ^contact_global_id}}
               }
             } = resp_decoded
    end

    test "`rejectContact` returns error when user is sender of the contact", %{
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
        graphql_query(conn, query: @reject_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"rejectContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["You can't reject a contact you sent."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["rejectContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`rejectContact` returns error when the contact isn't pending", %{
      conn: conn,
      user: current_user
    } do
      {:ok, %{user: contact_user}} = user_fixture()

      {:ok, %{contact: %{id: contact_id}}} =
        contact_fixture(:rejected, %{
          user_sender_id: contact_user.id,
          user_receiver_id: current_user.id
        })

      query_variables = %{
        input: %{
          id: to_global_id(:contact, contact_id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @reject_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"rejectContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["You can only reject a pending contact."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["rejectContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`rejectContact` returns error when the contact doesn't exist", %{
      conn: conn
    } do
      non_existing_contact_id = "Q29udGFjdDoz"

      query_variables = %{
        input: %{
          id: non_existing_contact_id
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @reject_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"rejectContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["Couldn't find such contact."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["rejectContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end

    test "`rejectContact` returns error when the user isn't sender/receiver of the contact", %{
      conn: conn
    } do
      {:ok, %{contact: %{id: contact_id}}} = contact_fixture(:pending, %{}, %{})

      query_variables = %{
        input: %{
          id: to_global_id(:contact, contact_id)
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @reject_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"rejectContact" => nil},
        "errors" => [
          %{
            "extensions" => %{
              "code" => "INVALID_INPUT",
              "details" => ["Contact doesn't belong to you."]
            },
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Validation error occured.",
            "path" => ["rejectContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end

  describe "when user isn't authorized" do
    test "`rejectContact` returns error", %{conn: conn} do
      query_variables = %{
        input: %{
          id: "Q29udGFjdDoz"
        }
      }

      %{resp_decoded: resp_decoded} =
        graphql_query(conn, query: @reject_contact_mutation, variables: query_variables)

      expected_response = %{
        "data" => %{"rejectContact" => nil},
        "errors" => [
          %{
            "extensions" => %{"code" => "UNAUTHENTICATED"},
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "You must be authenticated.",
            "path" => ["rejectContact"]
          }
        ]
      }

      assert resp_decoded == expected_response
    end
  end
end
