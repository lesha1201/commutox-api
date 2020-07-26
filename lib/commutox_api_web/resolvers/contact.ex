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

  def remove_contact(_, _) do
    {:error, "Not implemented"}
  end

  # Utils

  defp transform_domain_error(:add_contact, error_type) do
    Map.get(@add_contact_errors, error_type)
  end
end
