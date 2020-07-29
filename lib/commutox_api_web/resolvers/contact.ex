defmodule CommutoxApiWeb.Resolvers.Contact do
  alias CommutoxApi.{Contacts}
  alias CommutoxApiWeb.Errors

  # Queries

  def list_contacts(args, %{context: %{current_user: current_user}}) do
    case Contacts.list_user_contacts(current_user, args) do
      {:ok, result} ->
        {:ok, result}

      {:error, relay_error} ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{details: relay_error}
         })}
    end
  end

  def list_contacts(_, _) do
    {:error, Errors.unauthenticated()}
  end

  # Mutations

  @add_contact_input_errors [:already_exist, :no_contact_user, :same_user, :no_contact_user_key]

  @add_contact_errors %{
    already_exist: "You already have such contact.",
    no_contact_user: "Couldn't find such user.",
    same_user: "Contact user can't be the current user.",
    no_contact_user_key: "You must provide either id or email of contact user."
  }

  def add_contact(args, %{context: %{current_user: current_user}}) do
    case Contacts.add_contact(current_user, %{
           id: Map.get(args, :user_id),
           email: Map.get(args, :user_email)
         }) do
      {:ok, contact} ->
        {:ok, %{contact: contact}}

      {:error, error} when error in @add_contact_input_errors ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: [transform_domain_error(:add_contact, error)]
           }
         })}

      {:error, _error} ->
        {:error, Errors.internal_error()}
    end
  end

  def add_contact(_, _) do
    {:error, Errors.unauthenticated()}
  end

  @remove_contact_input_errors [:not_owner, :no_contact, :contact_is_incoming_request]

  @remove_contact_errors %{
    no_contact: "Couldn't find such contact.",
    not_owner: "Contact doesn't belong to you.",
    contact_is_incoming_request: "You can't remove pending or rejected incoming requests."
  }

  def remove_contact(args, %{context: %{current_user: current_user}}) do
    case Contacts.remove_contact(current_user, %{id: Map.get(args, :id)}) do
      {:ok, _contact} ->
        {:ok, %{success: true}}

      {:error, error} when error in @remove_contact_input_errors ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: [transform_domain_error(:remove_contact, error)]
           }
         })}

      {:error, _error} ->
        {:error, Errors.internal_error()}
    end
  end

  def remove_contact(_, _) do
    {:error, Errors.unauthenticated()}
  end

  @accept_contact_input_errors [
    :not_owner,
    :no_contact,
    :not_pending_contact,
    :user_is_sender
  ]

  @accept_contact_errors %{
    no_contact: "Couldn't find such contact.",
    not_owner: "Contact doesn't belong to you.",
    not_pending_contact: "You can only accept a pending contact.",
    user_is_sender: "You can't accept a contact you sent."
  }

  def accept_contact(args, %{context: %{current_user: current_user}}) do
    case Contacts.accept_contact(current_user, %{id: Map.get(args, :id)}) do
      {:ok, contact} ->
        {:ok, %{contact: contact}}

      {:error, error} when error in @accept_contact_input_errors ->
        {:error,
         Errors.invalid_input(%{
           extensions: %{
             details: [transform_domain_error(:accept_contact, error)]
           }
         })}

      {:error, _error} ->
        {:error, Errors.internal_error()}
    end
  end

  def accept_contact(_, _) do
    {:error, Errors.unauthenticated()}
  end

  # Utils

  defp transform_domain_error(:add_contact, error_type) do
    Map.get(@add_contact_errors, error_type)
  end

  defp transform_domain_error(:remove_contact, error_type) do
    Map.get(@remove_contact_errors, error_type)
  end

  defp transform_domain_error(:accept_contact, error_type) do
    Map.get(@accept_contact_errors, error_type)
  end
end
