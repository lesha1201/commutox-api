defmodule CommutoxApi.AccountsTest do
  use CommutoxApi.DataCase

  alias CommutoxApi.Accounts

  describe "users" do
    alias CommutoxApi.Accounts.User

    @valid_attrs %{
      email: "some@email",
      full_name: "some full_name",
      password: "some password",
      password_confirmation: "some password"
    }
    @update_attrs %{
      email: "some_updated@email",
      full_name: "some updated full_name",
      password: "some updated password",
      password_confirmation: "some updated password"
    }
    @invalid_attrs_1 %{email: nil, full_name: nil, password: nil, password_confirmation: nil}
    @invalid_attrs_2 %{
      email: "email with whitespaces",
      full_name: nil,
      password: nil,
      password_confirmation: nil
    }
    @invalid_attrs_3 %{
      email: "email@email",
      full_name: nil,
      password: "1234",
      password_confirmation: "4321"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email"
      assert user.full_name == "some full_name"
      assert user.password == nil
      assert_raise KeyError, fn -> user.password_confirmation end
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs_1)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs_2)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs_3)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some_updated@email"
      assert user.full_name == "some updated full_name"
      assert user.password == nil
      assert_raise KeyError, fn -> user.password_confirmation end
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs_1)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs_2)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs_3)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
