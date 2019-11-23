defmodule CommutoxApiWeb.Resolvers.AccountTest do
  use CommutoxApiWeb.ConnCase

  import Absinthe.Relay.Node

  alias CommutoxApi.Accounts
  alias CommutoxApiWeb.Schema

  @user_attrs %{
    email: "some@email",
    full_name: "some full_name",
    password: "some password",
    password_confirmation: "some password"
  }

  @user_schema_fields [:id, :email, :full_name]

  @users_query """
    query Users {
      users {
        #{build_query_fields(@user_schema_fields)}
      }
    }
  """

  @sign_up_mutation """
    mutation SignUp($input: SignUpInput!) {
      signUp(input: $input) {
        user {
          #{build_query_fields(@user_schema_fields)}
        }
        token
      }
    }
  """

  @sign_in_mutation """
    mutation SignIn($input: SignInInput!) {
      signIn(input: $input) {
        user {
          #{build_query_fields(@user_schema_fields)}
        }
        token
      }
    }
  """

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_attrs)
      |> Accounts.create_user()

    user
  end

  describe "queries" do
    test "`users` returns all users", %{conn: conn} do
      user =
        user_fixture()
        |> to_response_format(:user, [:email, :full_name, :id])

      expected_response = %{
        "data" => %{
          "users" => [user]
        }
      }

      %{resp_decoded: resp_decoded} = conn |> graphql_query(query: @users_query)

      assert Map.equal?(resp_decoded, expected_response)
    end

    test "`user` returns user by email", %{conn: conn} do
      query = """
        query User($email: String!) {
          user(email: $email) {
            id
            email
            fullName
          }
        }
      """

      query_variables = %{email: "test@test.com"}

      user =
        user_fixture(query_variables)
        |> to_response_format(:user, [:email, :full_name, :id])

      expected_response = %{
        "data" => %{
          "user" => user
        }
      }

      %{resp_decoded: resp_decoded} =
        conn |> graphql_query(query: query, variables: query_variables)

      assert Map.equal?(resp_decoded, expected_response)
    end
  end

  describe "mutations" do
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

    test "`sign_in` signs in a user and return user with token if credentials are correct",
         %{conn: conn} do
      user = user_fixture(@user_attrs)

      query_variables = %{
        input: %{
          email: @user_attrs.email,
          password: @user_attrs.password
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
end
