defmodule CommutoxApi.AccountsTest do
  use CommutoxApi.DataCase

  import CommutoxApi.Fixtures

  alias CommutoxApi.Accounts

  def seed_contact_statuses(_) do
    {:ok, %{contact_status: _pending_contact_status}} = contact_status_fixture(:pending)
    {:ok, %{contact_status: _accepted_contact_status}} = contact_status_fixture(:accepted)
    {:ok, %{contact_status: _rejected_contact_status}} = contact_status_fixture(:rejected)
  end

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

    test "list_users/0 returns all users" do
      {:ok, %{user: user}} = user_fixture()
      expected_users = [user] |> Enum.map(fn u -> %{u | password: nil} end)

      assert Accounts.list_users() == expected_users
    end

    test "get_user!/1 returns the user with given id" do
      {:ok, %{user: user}} = user_fixture()
      assert Accounts.get_user!(user.id) == %{user | password: nil}
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert Accounts.get_user!(user.id) == %{user | password: nil}
      assert_raise KeyError, fn -> user.password_confirmation end
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs_1)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs_2)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs_3)
    end

    test "update_user/2 with valid data updates the user" do
      {:ok, %{user: user}} = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some_updated@email"
      assert user.full_name == "some updated full_name"
      assert_raise KeyError, fn -> user.password_confirmation end
    end

    test "update_user/2 with invalid data returns error changeset" do
      {:ok, %{user: user}} = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs_1)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs_2)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs_3)
      assert Accounts.get_user!(user.id) == %{user | password: nil}
    end

    test "delete_user/1 deletes the user" do
      {:ok, %{user: user}} = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      {:ok, %{user: user}} = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "contact_statuses" do
    alias CommutoxApi.Accounts.ContactStatus

    test "list_contact_statuses/0 returns all contact_statuses" do
      {:ok, %{contact_status: pending_contact_status}} = contact_status_fixture(:pending)
      {:ok, %{contact_status: accepted_contact_status}} = contact_status_fixture(:accepted)
      {:ok, %{contact_status: rejected_contact_status}} = contact_status_fixture(:rejected)

      assert Accounts.list_contact_statuses() == [
               pending_contact_status,
               accepted_contact_status,
               rejected_contact_status
             ]
    end

    test "get_contact_status!/1 returns the contact_status with given code" do
      {:ok, %{contact_status: contact_status}} = contact_status_fixture(:pending)

      assert Accounts.get_contact_status!(contact_status.code) == contact_status
    end

    test "change_contact_status/1 returns a contact_status changeset" do
      assert %Ecto.Changeset{} = Accounts.change_contact_status(%ContactStatus{})
    end
  end

  describe "contacts" do
    alias CommutoxApi.Accounts.{Contact, ContactStatus}

    setup [:seed_contact_statuses]

    @update_attrs %{
      status_code: "ACC"
    }

    @invalid_attrs %{
      user_sender_id: 123,
      user_receiver_id: 456,
      status_code: "BLA"
    }

    test "list_contacts/0 returns all contacts" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})
      assert Accounts.list_contacts() == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})
      assert Accounts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      {:ok, %{user: user_sender}} = user_fixture()
      {:ok, %{user: user_receiver}} = user_fixture()
      pending_status = ContactStatus.Constants.pending()

      assert {:ok, %Contact{} = contact} =
               Accounts.create_contact(%{
                 user_sender_id: user_sender.id,
                 user_receiver_id: user_receiver.id,
                 status_code: pending_status.code
               })
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_contact(@invalid_attrs)
    end

    test "create_contact/1 can't create contact between two users that already has contact" do
      {:ok, %{contact: _contact, user_sender: user_sender, user_receiver: user_receiver}} =
        contact_fixture(:pending, %{}, %{})

      assert_raise Ecto.ConstraintError, fn ->
        contact_fixture(:pending, %{
          user_sender_id: user_sender.id,
          user_receiver_id: user_receiver.id
        })
      end

      assert_raise Ecto.ConstraintError, fn ->
        contact_fixture(:pending, %{
          user_sender_id: user_receiver.id,
          user_receiver_id: user_sender.id
        })
      end
    end

    test "update_contact/2 with valid data updates the contact" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})

      assert contact.status_code == "PND"
      assert {:ok, %Contact{} = contact} = Accounts.update_contact(contact, @update_attrs)
      assert contact.status_code == "ACC"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})

      assert {:error, %Ecto.Changeset{}} = Accounts.update_contact(contact, @invalid_attrs)
      assert contact == Accounts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})

      assert {:ok, %Contact{}} = Accounts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})

      assert %Ecto.Changeset{} = Accounts.change_contact(contact)
    end
  end
end
