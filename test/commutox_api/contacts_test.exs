defmodule CommutoxApi.ContactsTest do
  use CommutoxApi.DataCase

  import CommutoxApi.Fixtures

  alias CommutoxApi.Contacts
  alias CommutoxApi.Contacts.Contact

  describe "add_contact" do
    setup _context do
      seed_contact_statuses()
    end

    test "creates a new contact when it doesn't exist" do
      {:ok, %{user: %{id: current_user_id} = current_user}} = user_fixture()
      {:ok, %{user: %{id: contact_user_id} = contact_user}} = user_fixture()

      pending_status_code = Contacts.Constants.pending().code

      assert Contacts.Store.get_contact_by(
               user_sender_id: current_user.id,
               user_receiver_id: contact_user.id
             ) == nil

      assert Contacts.Store.get_contact_by(
               user_sender_id: contact_user.id,
               user_receiver_id: current_user.id
             ) == nil

      assert {:ok,
              %Contact{
                user_sender_id: ^current_user_id,
                user_receiver_id: ^contact_user_id,
                status_code: ^pending_status_code
              }} = Contacts.add_contact(current_user, contact_user)
    end

    test "updates an existing contact when the current user is receiver" do
      {:ok, %{user: %{id: current_user_id} = current_user}} = user_fixture()
      {:ok, %{user: %{id: contact_user_id} = contact_user}} = user_fixture()

      {:ok, %{contact: %{id: existing_contact_id}}} =
        contact_fixture(:pending, %{
          user_sender_id: contact_user_id,
          user_receiver_id: current_user_id
        })

      accepted_status_code = Contacts.Constants.accepted().code

      assert {:ok,
              %Contact{
                id: ^existing_contact_id,
                user_sender_id: ^contact_user_id,
                user_receiver_id: ^current_user_id,
                status_code: ^accepted_status_code
              } = contact} = Contacts.add_contact(current_user, contact_user)
    end

    test "returns error when contact_user is the current user" do
      {:ok, %{user: current_user}} = user_fixture()

      assert {:error, :same_user} = Contacts.add_contact(current_user, current_user)
    end

    test "returns error when the current user already created such contact" do
      {:ok, %{user: %{id: current_user_id} = current_user}} = user_fixture()
      {:ok, %{user: %{id: contact_user_id} = contact_user}} = user_fixture()

      {:ok, %{contact: _contact}} =
        contact_fixture(:pending, %{
          user_sender_id: current_user_id,
          user_receiver_id: contact_user_id
        })

      assert {:error, :already_exist} = Contacts.add_contact(current_user, contact_user)
    end

    test "returns error when arguments are invalid" do
      {:ok, %{user: current_user}} = user_fixture()

      assert {:error, :no_contact_user_key} = Contacts.add_contact(current_user, %{})
    end
  end

  describe "remove_contact" do
    setup _context do
      seed_contact_statuses()
    end

    test "removes a contact when the actor user is sender of the contact" do
      {:ok, %{user: %{id: actor_user_id} = actor_user}} = user_fixture()
      {:ok, %{user: %{id: contact_user_id}}} = user_fixture()

      {:ok, %{contact: %{id: contact_id} = contact}} =
        contact_fixture(:pending, %{
          user_sender_id: actor_user_id,
          user_receiver_id: contact_user_id
        })

      assert Contacts.Store.get_contact(contact_id) != nil
      assert {:ok, %Contact{id: ^contact_id}} = Contacts.remove_contact(actor_user, contact)
      assert Contacts.Store.get_contact(contact_id) == nil

      {:ok, %{contact: %{id: contact_id} = contact}} =
        contact_fixture(:accepted, %{
          user_sender_id: actor_user_id,
          user_receiver_id: contact_user_id
        })

      assert Contacts.Store.get_contact(contact_id) != nil
      assert {:ok, %Contact{id: ^contact_id}} = Contacts.remove_contact(actor_user, contact)
      assert Contacts.Store.get_contact(contact_id) == nil

      {:ok, %{contact: %{id: contact_id} = contact}} =
        contact_fixture(:rejected, %{
          user_sender_id: actor_user_id,
          user_receiver_id: contact_user_id
        })

      assert Contacts.Store.get_contact(contact_id) != nil
      assert {:ok, %Contact{id: ^contact_id}} = Contacts.remove_contact(actor_user, contact)
      assert Contacts.Store.get_contact(contact_id) == nil
    end

    test "updates a contact when the actor user is receiver and the contact is accepted" do
      {:ok, %{user: %{id: actor_user_id} = actor_user}} = user_fixture()
      {:ok, %{user: %{id: contact_user_id}}} = user_fixture()

      {:ok, %{contact: %{id: contact_id} = contact}} =
        contact_fixture(:accepted, %{
          user_sender_id: contact_user_id,
          user_receiver_id: actor_user_id
        })

      accepted_status_code = Contacts.Constants.accepted().code
      rejected_status_code = Contacts.Constants.rejected().code

      assert %Contact{id: ^contact_id, status_code: ^accepted_status_code} =
               Contacts.Store.get_contact(contact_id)

      assert {:ok, %Contact{id: ^contact_id, status_code: ^rejected_status_code}} =
               Contacts.remove_contact(actor_user, contact)

      assert %Contact{id: ^contact_id, status_code: ^rejected_status_code} =
               Contacts.Store.get_contact(contact_id)
    end

    test "returns error if the actor user doesn't exist" do
      {:ok, %{contact: contact}} = contact_fixture(:accepted, %{}, %{})

      assert {:error, :no_actor_user} = Contacts.remove_contact(%{id: -1}, contact)
      assert {:error, :no_actor_user} = Contacts.remove_contact(%{id: -1}, %{id: -1})
    end

    test "returns error if the contact doesn't exist" do
      {:ok, %{user: actor_user}} = user_fixture()

      assert {:error, :no_contact} = Contacts.remove_contact(actor_user, %{id: -1})
    end

    test "returns error if the actor user isn't sender/receiver of the contact" do
      {:ok, %{user: actor_user}} = user_fixture()
      {:ok, %{contact: contact}} = contact_fixture(:accepted, %{}, %{})

      assert {:error, :not_owner} = Contacts.remove_contact(actor_user, contact)
    end

    test "returns error if the contact is pending/rejected incoming request (the actor user is receiver)" do
      {:ok, %{user: %{id: actor_user_id} = actor_user}} = user_fixture()
      {:ok, %{user: %{id: contact_user_id}}} = user_fixture()

      {:ok, %{contact: %{id: contact_id} = contact}} =
        contact_fixture(:pending, %{
          user_sender_id: contact_user_id,
          user_receiver_id: actor_user_id
        })

      pending_status_code = Contacts.Constants.pending().code
      rejected_status_code = Contacts.Constants.rejected().code

      assert contact.status_code == pending_status_code
      assert {:error, :contact_is_incoming_request} = Contacts.remove_contact(actor_user, contact)

      {:ok, contact} =
        Contacts.Store.update_contact(contact, %{status_code: rejected_status_code})

      assert contact.status_code == rejected_status_code
      assert {:error, :contact_is_incoming_request} = Contacts.remove_contact(actor_user, contact)
    end
  end
end
