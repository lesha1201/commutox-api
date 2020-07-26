defmodule CommutoxApi.Contacts.Domain.AddContact do
  @moduledoc false

  alias Ecto.Multi
  alias CommutoxApi.Repo
  alias CommutoxApi.{Accounts, Contacts}
  alias CommutoxApi.Contacts.{Contact, Constants}
  alias CommutoxUtils, as: Utils

  @type add_contact_error ::
          :no_contact_user_key | :already_exist | :no_actor_user | :no_contact_user | :same_user

  @spec perform(map, map) ::
          {:ok, Contact.t()}
          | {:error, add_contact_error}
          | {:error, :ecto_changeset, Ecto.Changeset.t()}
  def perform(actor_user, contact_user) do
    {user_key, user_key_value} = Utils.Map.get_one_of(contact_user, [:id, :email]) || {nil, nil}

    if user_key_value == nil do
      {:error, :no_contact_user_key}
    else
      perform_transaction(actor_user, {user_key, user_key_value})
    end
  end

  defp perform_transaction(actor_user, {user_key, user_key_value}) do
    Multi.new()
    |> Multi.run(:get_users, fn _repo, _changes ->
      get_users(actor_user, {user_key, user_key_value})
    end)
    |> Multi.run(:create_or_update_contact, fn _repo,
                                               %{
                                                 get_users: %{
                                                   actor_user: actor_user,
                                                   contact_user: contact_user
                                                 }
                                               } ->
      {contact_type, contact} = get_contact(actor_user, contact_user)

      case contact_type do
        :sent ->
          {:error, :already_exist}

        :received ->
          update_contact(contact)

        :none ->
          Contacts.Store.create_contact(%{
            user_sender_id: actor_user.id,
            user_receiver_id: contact_user.id
          })
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_or_update_contact: contact}} ->
        {:ok, contact}

      {:error, :get_users, error, _} ->
        {:error, error}

      {:error, :create_or_update_contact, %Ecto.Changeset{} = changeset, _} ->
        {:error, :ecto_changeset, changeset}

      {:error, :create_or_update_contact, error, _} ->
        {:error, error}

      _ ->
        {:error, :unknown}
    end
  end

  defp get_users(actor_user, {user_key, user_key_value}) do
    contact_user = Accounts.Store.get_user_by([{user_key, user_key_value}])
    actor_user = Accounts.Store.get_user(actor_user.id)

    cond do
      actor_user == nil ->
        {:error, :no_actor_user}

      contact_user == nil ->
        {:error, :no_contact_user}

      # TODO: we should probably create a constraint in SQL for that
      contact_user.id == actor_user.id ->
        {:error, :same_user}

      true ->
        {:ok, %{actor_user: actor_user, contact_user: contact_user}}
    end
  end

  defp get_contact(actor_user, contact_user) do
    cond do
      contact =
          Contacts.Store.get_contact_by(
            user_sender_id: actor_user.id,
            user_receiver_id: contact_user.id
          ) ->
        {:sent, contact}

      contact =
          Contacts.Store.get_contact_by(
            user_sender_id: contact_user.id,
            user_receiver_id: actor_user.id
          ) ->
        {:received, contact}

      true ->
        {:none, nil}
    end
  end

  defp update_contact(contact) do
    accepted_status_code = Constants.accepted().code

    if contact.status === accepted_status_code do
      {:error, :already_exist}
    else
      Contacts.Store.update_contact(contact, %{
        status_code: Constants.accepted().code
      })
    end
  end
end
