defmodule CommutoxApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias CommutoxApi.Repo

  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Accounts.Contact
  alias CommutoxApi.Accounts.ContactStatus

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by email.

  Returns `nil` if the User does not exist.
  """
  def get_user_by(clauses), do: Repo.get_by(User, clauses)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns the list of contact statuses.

  ## Examples

      iex> list_contact_statuses()
      [%ContactStatus{}, ...]

  """
  def list_contact_statuses do
    Repo.all(ContactStatus)
  end

  @doc """
  Gets a single contact status.

  Raises `Ecto.NoResultsError` if the Contact status does not exist.

  ## Examples

      iex> get_contact_status!(123)
      %ContactStatus{}

      iex> get_contact_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_status!(code), do: Repo.get!(ContactStatus, code)

  @doc """
  Gets a single contact status.

  Returns `nil` if the Contact status does not exist.

  ## Examples

      iex> get_contact_status(123)
      %ContactStatus{}

      iex> get_contact_status(456)
      nil

  """
  def get_contact_status(code), do: Repo.get(ContactStatus, code)

  @doc """
  Creates a contact status.

  ## Examples

      iex> create_contact_status(%{field: value})
      {:ok, %ContactStatus{}}

      iex> create_contact_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_status(attrs \\ %{}) do
    %ContactStatus{}
    |> ContactStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact_status changes.

  ## Examples

      iex> change_contact_status(contact_status)
      %Ecto.Changeset{source: %ContactStatus{}}

  """
  def change_contact_status(%ContactStatus{} = contact_status) do
    ContactStatus.changeset(contact_status, %{})
  end

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts do
    Repo.all(Contact)
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  @doc """
  Gets a single contact.

  Returns `nil` if the Contact does not exist.

  ## Examples

      iex> get_contact(123)
      %Contact{}

      iex> get_contact(456)
      nil

  """
  def get_contact(id), do: Repo.get(Contact, id)

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Contact{}}

  """
  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end
end
