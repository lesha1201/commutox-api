defmodule CommutoxApiWeb.Graphql.Mutations.SignUpTest do
  use CommutoxApiWeb.ConnCase

  import Absinthe.Relay.Node
  import CommutoxApiWeb.GraphqlHelpers

  alias CommutoxApi.Accounts
  alias CommutoxApiWeb.Schema

  @sign_up_mutation """
  mutation SignUp($input: SignUpInput!) {
    signUp(input: $input) {
      user {
        id
        email
        fullName
      }
      token
    }
  }
  """

  test "`sign_up` creates user in database and returns user with token", %{conn: conn} do
    query_variables = %{
      input: %{
        email: "test@test.com",
        full_name: "Full Name",
        password: "password",
        password_confirmation: "password"
      }
    }

    %{resp_decoded: resp_decoded} =
      conn |> graphql_query(query: @sign_up_mutation, variables: query_variables)

    assert %{
             "data" => %{
               "signUp" => %{"user" => %{"id" => global_id} = resp_user, "token" => token}
             }
           } = resp_decoded

    user_without_id = from_response_format(resp_user) |> Map.drop([:id])
    expected_user_without_id = query_variables.input |> Map.take([:email, :full_name])

    assert Map.equal?(user_without_id, expected_user_without_id)

    {:ok, %{id: id}} = from_global_id(global_id, Schema)

    user_from_database = Accounts.get_user(id)

    assert user_from_database != nil
    assert {:ok, _claims} = Accounts.Guardian.decode_and_verify(token)
  end

  test "`sign_up` returns error when input is invalid", %{conn: conn} do
    query_variables = %{
      input: %{
        email: "invalid email",
        full_name: "Full Name",
        password: "pass",
        password_confirmation: "ssap"
      }
    }

    %{resp_decoded: resp_decoded} =
      graphql_query(conn, query: @sign_up_mutation, variables: query_variables)

    expected_response = %{
      "data" => %{"signUp" => nil},
      "errors" => [
        %{
          "extensions" => %{
            "code" => "INVALID_INPUT",
            "details" => %{
              "email" => ["has invalid format"],
              "password" => ["should be at least 8 character(s)"],
              "passwordConfirmation" => ["does not match confirmation"]
            }
          },
          "locations" => [%{"column" => 3, "line" => 2}],
          "message" => "Validation error occured.",
          "path" => ["signUp"]
        }
      ]
    }

    assert resp_decoded == expected_response
  end
end
