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
end
