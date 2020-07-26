defmodule CommutoxApi.Contacts do
  @moduledoc """
  The Contacts context. Contains business/domain logic.
  """

  alias CommutoxApi.Contacts.Contact
  alias CommutoxApi.Contacts.Domain.{AddContact, ListUserContacts}

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
end
