defmodule CommutoxApi.Contacts.Store do
  @moduledoc """
  Database CRUD operations for Contacts context.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Repo
  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Contacts.{Contact, ContactStatus}

  # *****************
  # * ContactStatus *
  # *****************

  @spec list_contact_statuses :: list(ContactStatus.t())
  def list_contact_statuses do
    Repo.all(ContactStatus)
  end

  @spec get_contact_status(ContactStatus.code()) :: ContactStatus.t() | nil
  def get_contact_status(code), do: Repo.get(ContactStatus, code)

  @spec create_contact_status(map) :: {:ok, ContactStatus.t()} | {:error, Ecto.Changeset.t()}
  def create_contact_status(attrs \\ %{}) do
    %ContactStatus{}
    |> ContactStatus.changeset(attrs)
    |> Repo.insert()
  end

  # ***********
  # * Contact *
  # ***********

  @spec list_contacts :: list(Contact.t())
  def list_contacts do
    Repo.all(Contact)
  end

  @spec get_contact(T.id()) :: Contact.t() | nil
  def get_contact(id), do: Repo.get(Contact, id)

  @spec(get_contact_by(keyword()) :: Contact.t(), nil)
  def get_contact_by(clauses), do: Repo.get_by(Contact, clauses)

  @spec create_contact(map) :: {:ok, Contact.t()} | {:error, Ecto.Changeset.t()}
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_contact(Contact.t(), map) :: {:ok, Contact.t()} | {:error, Ecto.Changeset.t()}
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_contact(Contact.t()) :: {:ok, Contact.t()} | {:error, Ecto.Changeset.t()}
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end
end
