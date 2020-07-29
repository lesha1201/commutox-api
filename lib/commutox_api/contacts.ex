defmodule CommutoxApi.Contacts do
  @moduledoc """
  The Contacts context. Contains business/domain logic.
  """

  alias CommutoxApi.Contacts.Contact

  alias CommutoxApi.Contacts.Domain.{
    AcceptContact,
    AddContact,
    ListUserContacts,
    RejectContact,
    RemoveContact
  }

  @doc """
  Returns the `user`'s contacts in Relay representation.

  ## Examples

      iex> list_user_contacts(current_user)
      {
        :ok,
        %{
          edges: [%{node: %Contact{}, cursor: cursor}],
          page_info: page_info
        }
      }
  """
  @spec list_user_contacts(ListUserContacts.user(), ListUserContacts.relay_options()) ::
          ListUserContacts.result()
  def list_user_contacts(user, args \\ %{}) do
    ListUserContacts.perform(user, args)
  end

  @doc """
  Adds contact for the current user. If the current user already received a request from
  `contact_user` then it updates the contact status to Accepted.

  ## Examples

      iex> add_contact(current_user, contact_user)
      {:ok, %Contact{}}

      iex> add_contact(current_user, current_user)
      {:error, :same_user}
  """
  @spec add_contact(map, map) ::
          {:error, AddContact.add_contact_error()}
          | {:ok, Contact.t()}
          | {:error, :ecto_changeset, Ecto.Changeset.t()}
  def add_contact(actor_user, contact_user) do
    AddContact.perform(actor_user, contact_user)
  end

  @doc """
  Removes a contact from the `actor_user`. If the `actor_user` is sender it will delete
  the contact from DB otherwise it will update the contact status to `REJ`.

  ## Examples

      iex> remove_contact(actor_user, contact)
      {:ok, %Contact{}}

      iex> remove_contact(actor_user, contact)
      {:error, :no_contact}
  """
  @spec remove_contact(RemoveContact.actor_user(), RemoveContact.contact()) ::
          RemoveContact.result()
  def remove_contact(actor_user, contact) do
    RemoveContact.perform(actor_user, contact)
  end

  @doc """
  Accepts a contact request for the `user`. It can only accept a pending contact.

  ## Examples

      iex> accept_contact(user, contact)
      {:ok, %Contact{}}

      iex> accept_contact(user, contact)
      {:error, :not_pending_contact}
  """
  @spec accept_contact(AcceptContact.user(), AcceptContact.contact()) ::
          AcceptContact.result()
  def accept_contact(user, contact) do
    AcceptContact.perform(user, contact)
  end

  @doc """
  Rejects a contact request for the `user`. It can only reject a pending contact.

  ## Examples

      iex> reject_contact(user, contact)
      {:ok, %Contact{}}

      iex> reject_contact(user, contact)
      {:error, :not_pending_contact}
  """
  @spec reject_contact(RejectContact.user(), RejectContact.contact()) ::
          RejectContact.result()
  def reject_contact(user, contact) do
    RejectContact.perform(user, contact)
  end
end
