defmodule CommutoxApi.Contacts.StoreTest do
  use CommutoxApi.DataCase

  import CommutoxApi.Fixtures

  alias CommutoxApi.Contacts

  describe "contact_statuses" do
    test "list_contact_statuses/0 returns all contact_statuses" do
      {:ok, %{contact_status: pending_contact_status}} = contact_status_fixture(:pending)
      {:ok, %{contact_status: accepted_contact_status}} = contact_status_fixture(:accepted)
      {:ok, %{contact_status: rejected_contact_status}} = contact_status_fixture(:rejected)

      assert Contacts.Store.list_contact_statuses() == [
               pending_contact_status,
               accepted_contact_status,
               rejected_contact_status
             ]
    end

    test "get_contact_status/1 returns the contact_status with given code" do
      {:ok, %{contact_status: contact_status}} = contact_status_fixture(:pending)

      assert Contacts.Store.get_contact_status(contact_status.code) == contact_status
    end
  end

  describe "contacts" do
    alias CommutoxApi.Contacts.Contact

    setup _context do
      seed_contact_statuses()
    end

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
      assert Contacts.Store.list_contacts() == [contact]
    end

    test "get_contact/1 returns the contact with given id" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})
      assert Contacts.Store.get_contact(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      {:ok, %{user: user_sender}} = user_fixture()
      {:ok, %{user: user_receiver}} = user_fixture()
      pending_status = Contacts.Constants.pending()

      assert {:ok, %Contact{} = contact} =
               Contacts.Store.create_contact(%{
                 user_sender_id: user_sender.id,
                 user_receiver_id: user_receiver.id,
                 status_code: pending_status.code
               })
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.Store.create_contact(@invalid_attrs)
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
      assert {:ok, %Contact{} = contact} = Contacts.Store.update_contact(contact, @update_attrs)
      assert contact.status_code == "ACC"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})

      assert {:error, %Ecto.Changeset{}} = Contacts.Store.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.Store.get_contact(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      {:ok, %{contact: contact}} = contact_fixture(:pending, %{}, %{})

      assert {:ok, %Contact{}} = Contacts.Store.delete_contact(contact)
      assert Contacts.Store.get_contact(contact.id) == nil
    end
  end
end
