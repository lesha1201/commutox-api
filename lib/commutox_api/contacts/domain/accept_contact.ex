defmodule CommutoxApi.Contacts.Domain.AcceptContact do
  @moduledoc false

  alias Ecto.Multi
  alias CommutoxApi.Repo
  alias CommutoxApi.Types, as: T
  alias CommutoxApi.{Accounts, Contacts}
  alias CommutoxApi.Contacts.Contact
  alias CommutoxApi.Contacts.Domain.Utils

  @type user :: %{id: T.id()}
  @type contact :: %{id: T.id()}
  @type error ::
          :not_owner | :no_user | :no_contact | :not_pending_contact | :user_is_sender | :unknown
  @type result ::
          {:ok, Contact.t()} | {:error, error} | {:error, :ecto_changeset, Ecto.Changeset.t()}

  @spec perform(user, contact) :: result
  def perform(%{id: user_id}, %{id: contact_id}) do
    Multi.new()
    |> Multi.run(:user, fn _repo, _changes ->
      case Accounts.Store.get_user(user_id) do
        nil ->
          {:error, :no_user}

        user ->
          {:ok, user}
      end
    end)
    |> Multi.run(:contact, fn _repo, _changes ->
      case Contacts.Store.get_contact(contact_id) do
        nil ->
          {:error, :no_contact}

        contact ->
          {:ok, contact}
      end
    end)
    |> Multi.run(:user_contact_type, fn _repo, %{user: user, contact: contact} ->
      Utils.get_user_contact_type(user, contact)
    end)
    |> Multi.run(:update_contact, fn _repo, changes ->
      update_contact(changes.user_contact_type, changes.contact)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{update_contact: contact}} ->
        {:ok, contact}

      {:error, :user, error, _} ->
        {:error, error}

      {:error, :contact, error, _} ->
        {:error, error}

      {:error, :user_contact_type, error, _} ->
        {:error, error}

      {:error, :update_contact, %Ecto.Changeset{} = changeset, _} ->
        {:error, :ecto_changeset, changeset}

      {:error, :update_contact, error, _} ->
        {:error, error}

      _ ->
        {:error, :unknown}
    end
  end

  defp update_contact(:receiver, contact) do
    pending_status_code = Contacts.Constants.pending().code

    if contact.status_code == pending_status_code do
      Contacts.Store.update_contact(contact, %{
        status_code: Contacts.Constants.accepted().code
      })
    else
      {:error, :not_pending_contact}
    end
  end

  defp update_contact(:sender, _contact) do
    {:error, :user_is_sender}
  end
end
