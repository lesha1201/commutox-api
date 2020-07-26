defmodule CommutoxApi.Contacts.Domain.RemoveContact do
  @moduledoc false

  alias Ecto.Multi
  alias CommutoxApi.Types, as: T
  alias CommutoxApi.Repo
  alias CommutoxApi.{Accounts, Contacts}
  alias CommutoxApi.Contacts.{Contact, Constants}

  @type error :: :not_owner | :no_actor_user | :no_contact | :contact_is_incoming_request
  @type actor_user :: %{id: T.id()}
  @type contact :: %{id: T.id()}
  @type result ::
          {:ok, Contact.t()} | {:error, error} | {:error, :ecto_changeset, Ecto.Changeset.t()}

  @spec perform(actor_user, contact) :: result
  def perform(%{id: actor_user_id}, %{id: contact_id}) do
    Multi.new()
    |> Multi.run(:actor_user, fn _repo, _changes ->
      case Accounts.Store.get_user(actor_user_id) do
        nil ->
          {:error, :no_actor_user}

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
    |> Multi.run(:user_contact_type, fn _repo, %{actor_user: actor_user, contact: contact} ->
      get_user_contact_type(actor_user, contact)
    end)
    |> Multi.run(:delete_contact, fn _repo, changes ->
      delete_contact(changes.user_contact_type, changes.contact)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{delete_contact: contact}} -> {:ok, contact}
      {:error, :actor_user, error, _} -> {:error, error}
      {:error, :contact, error, _} -> {:error, error}
      {:error, :user_contact_type, error, _} -> {:error, error}
      {:error, :delete_contact, error, _} -> {:error, error}
      _ -> {:error, :unknown}
    end
  end

  defp get_user_contact_type(user, %{
         user_receiver_id: user_receiver_id,
         user_sender_id: user_sender_id
       }) do
    case user.id do
      ^user_receiver_id ->
        {:ok, :receiver}

      ^user_sender_id ->
        {:ok, :sender}

      _ ->
        {:error, :not_owner}
    end
  end

  defp delete_contact(:sender, contact) do
    Contacts.Store.delete_contact(contact)
  end

  defp delete_contact(:receiver, contact) do
    accepted_code = Constants.accepted().code

    if contact.status_code == accepted_code do
      Contacts.Store.update_contact(contact, %{
        status_code: Constants.rejected().code
      })
    else
      {:error, :contact_is_incoming_request}
    end
  end
end
