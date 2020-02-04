defmodule CommutoxApiWeb.Graphql.Mutations.SignUpTest do
  use CommutoxApiWeb.ConnCase

  import CommutoxApiWeb.GraphqlHelpers
  import CommutoxApi.Fixtures

  alias CommutoxApi.Accounts

  @sign_in_mutation """
  mutation SignIn($input: SignInInput!) {
    signIn(input: $input) {
      user {
        id
        email
        fullName
      }
      token
    }
  }
  """

  test "`sign_in` signs in a user and return user with token if credentials are correct", %{
    conn: conn
  } do
    user_attrs = %{
      email: "some@email",
      full_name: "some full_name",
      password: "some password",
      password_confirmation: "some password"
    }

    {:ok, %{user: user}} = user_fixture(user_attrs)

    query_variables = %{
      input: %{
        email: user_attrs.email,
        password: user_attrs.password
      }
    }

    %{resp_decoded: resp_decoded} =
      conn |> graphql_query(query: @sign_in_mutation, variables: query_variables)

    assert %{
             "data" => %{
               "signIn" => %{"user" => resp_user, "token" => token}
             }
           } = resp_decoded

    assert user.email == resp_user["email"]
    assert {:ok, _claims} = Accounts.Guardian.decode_and_verify(token)
  end
end
