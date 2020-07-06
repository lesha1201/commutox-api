defmodule CommutoxApi.Accounts.Contact.AddContact do
  @moduledoc """
  Contains business logic for performing contact's mutations.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias CommutoxApi.Repo
  alias CommutoxApi.Accounts
  alias Accounts.ContactStatus

  @errors %{
    already_exist: "You already have such contact.",
    no_user: "Couldn't find such user.",
    same_user: "Contact user can't be the current user.",
    unknown: "Something went wrong.",
    no_contact_user_key: "You must provide either id or email of contact user."
  }

  def perform(%{current_user: current_user, contact_user: contact_user}) do
    user_key =
      cond do
        Map.get(contact_user, :id) ->
          :id

        Map.get(contact_user, :email) ->
          :email

        true ->
          nil
      end

    user_key_value = Map.get(contact_user, user_key)

    Multi.new()
    |> Multi.run(:check_arguments, fn _repo, _changes ->
      if user_key_value == nil do
        {:error, @errors.no_contact_user_key}
      else
        {:ok, nil}
      end
    end)
    |> Multi.run(:receiver_user, fn _repo, _changes ->
      user = Accounts.get_user_by([{user_key, user_key_value}])

      cond do
        user === nil ->
          {:error, @errors.no_user}

        # TODO: we should probably create a constraint in SQL for that
        user.id === current_user.id ->
          {:error, @errors.same_user}

        true ->
          {:ok, user}
      end
    end)
    |> Multi.run(:create_or_update_contact, fn _repo, %{receiver_user: receiver_user} ->
      {contact_type, contact} =
        cond do
          contact =
              Accounts.get_contact_by(
                user_sender_id: current_user.id,
                user_receiver_id: receiver_user.id
              ) ->
            {:sent, contact}

          contact =
              Accounts.get_contact_by(
                user_sender_id: receiver_user.id,
                user_receiver_id: current_user.id
              ) ->
            {:received, contact}

          true ->
            {:none, nil}
        end

      case contact_type do
        :sent ->
          {:error, @errors.already_exist}

        :received ->
          accepted_status_code = ContactStatus.Constants.accepted().code

          if contact.status === accepted_status_code do
            {:error, @errors.already_exist}
          else
            Accounts.update_contact(contact, %{
              status_code: ContactStatus.Constants.accepted().code
            })
          end

        :none ->
          Accounts.create_contact(%{
            user_sender_id: current_user.id,
            user_receiver_id: receiver_user.id
          })
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_or_update_contact: contact}} ->
        {:ok, contact}

      {:error, :receiver_user, error, _} ->
        {:error, error}

      {:error, :create_or_update_contact, error, _} ->
        {:error, error}

      {:error, :check_arguments, error, _} ->
        {:error, error}

      _ ->
        {:error, @errors.unknown}
    end
  end
end
