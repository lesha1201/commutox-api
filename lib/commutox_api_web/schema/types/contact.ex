defmodule CommutoxApiWeb.Schema.Types.Contact do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  alias CommutoxApiWeb.Errors
  alias CommutoxApiWeb.Resolvers

  # Enums

  @desc "Possible contact statuses."
  enum :contact_status do
    value(:pending,
      as: "PND",
      description: "Tells that sender is pending an answer from the receiver."
    )

    value(:accepted,
      as: "ACC",
      description: "Tells that receiver accepted a request from the sender."
    )

    value(:rejected,
      as: "REJ",
      description: "Tells that receiver rejected a request from the sender."
    )
  end

  @desc "Possible contact types. Determines whether a user received request for contact or sent it."
  enum :contact_type do
    value(:received,
      description: "Tells that a user received a request for adding to its contact list."
    )

    value(:sent,
      description: "Tells that a user sent a request for adding to its contact list."
    )
  end

  # Queries

  object :contact_queries do
    @desc "Gets a list of current user's contacts"
    connection field(:contacts, node_type: :contact) do
      resolve(&Resolvers.Contact.list_contacts/2)
    end
  end

  # Mutations

  object :contact_mutations do
    @desc """
    Adds contact for the current user. If the current user already received a request from the provided user then it
    updates the contact status to Accepted.
    """
    payload field(:add_contact) do
      @desc """
      Either `userId` or `userEmail` is required.
      """
      input do
        field :user_id, :id
        field :user_email, :string
      end

      output do
        field :contact, non_null(:contact)
      end

      parsing_node_ids(&Resolvers.Contact.add_contact/2, user_id: :user)
      |> resolve()
    end

    @desc """
    Removes contact from the current user's contacts. If a contact is accepted and the current user is receiver then it
    will update the contact status to `REJECTED`.
    """
    payload field(:remove_contact) do
      input do
        @desc "ID of Contact"
        field :id, non_null(:id)
      end

      output do
        field :success, non_null(:boolean)
      end

      parsing_node_ids(&Resolvers.Contact.remove_contact/2, id: :contact)
      |> resolve()
    end

    @desc """
    Accepts a contact request for the current user. It can only accept a pending contact.
    """
    payload field(:accept_contact) do
      input do
        @desc "ID of Contact"
        field :id, non_null(:id)
      end

      output do
        field :contact, non_null(:contact)
      end

      parsing_node_ids(&Resolvers.Contact.accept_contact/2, id: :contact)
      |> resolve()
    end

    @desc """
    Rejects a contact request for the current user. It can only reject a pending contact.
    """
    payload field(:reject_contact) do
      input do
        @desc "ID of Contact"
        field :id, non_null(:id)
      end

      output do
        field :contact, non_null(:contact)
      end

      parsing_node_ids(&Resolvers.Contact.reject_contact/2, id: :contact)
      |> resolve()
    end
  end

  # Objects

  connection(node_type: :contact)

  defp get_contact_type(contact, %{current_user: current_user}) do
    user_sender_id = Map.get(contact, :user_sender_id)
    user_receiver_id = Map.get(contact, :user_receiver_id)

    case current_user.id do
      ^user_sender_id ->
        {:ok, :sent}

      ^user_receiver_id ->
        {:ok, :received}

      _ ->
        {:error, Errors.internal_error(%{message: "Couldn't resolve contact type."})}
    end
  end

  node object(:contact) do
    field :inserted_at, non_null(:naive_datetime)

    field :status, non_null(:contact_status),
      resolve: fn parent, _, _ -> {:ok, Map.get(parent, :status_code)} end

    field :type, :contact_type,
      resolve: fn parent, _, %{context: %{current_user: current_user}} ->
        get_contact_type(parent, %{current_user: current_user})
      end

    @desc "Second-party user. It's either `userSender` or `userReceiver` depending on which one is the current user."
    field :user, :user,
      resolve: fn parent, args, %{context: %{current_user: current_user}} = resolution ->
        case get_contact_type(parent, %{current_user: current_user}) do
          {:ok, type} ->
            resource =
              case type do
                :sent -> :user_receiver
                :received -> :user_sender
              end

            dataloader(:commutox_repo, resource, []).(parent, args, resolution)

          {:error, error} ->
            {:error, error}
        end
      end

    field :user_sender, non_null(:user), resolve: dataloader(:commutox_repo)
    field :user_receiver, non_null(:user), resolve: dataloader(:commutox_repo)
  end
end
