defmodule CommutoxApiWeb.Schema.Types.Account do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3, on_load: 2]

  alias Absinthe.Relay.Connection
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

  object :account_queries do
    @desc "Gets a list of all users"
    connection field(:users, node_type: :user) do
      resolve(&Resolvers.Account.list_users/2)
    end

    @desc "Gets a user by email."
    field :user, :user do
      arg(:email, non_null(:string))
      resolve(&Resolvers.Account.user/3)
    end

    @desc "Gets a list of current user's contacts"
    connection field(:contacts, node_type: :contact) do
      resolve(&Resolvers.Account.list_contacts/2)
    end
  end

  # Mutations

  object :account_mutations do
    @desc "Signs up a user"
    payload field(:sign_up) do
      input do
        field :email, non_null(:string)
        field :full_name, non_null(:string)
        field :password, non_null(:string)
        field :password_confirmation, non_null(:string)
      end

      output do
        field :token, non_null(:string)
        field :user, non_null(:user)
      end

      resolve(&Resolvers.Account.sign_up/2)
    end

    @desc "Signs in a user"
    payload field(:sign_in) do
      input do
        field :email, non_null(:string)
        field :password, non_null(:string)
      end

      output do
        field :token, non_null(:string)
        field :user, non_null(:user)
      end

      resolve(&Resolvers.Account.sign_in/2)
    end

    @desc """
    Adds contact for the current user. If the current user already received a request from the provided user then it updates the contact status to Accepted.
    """
    payload field(:add_contact) do
      @desc """
      Either `userId` or `userEmail` is required.
      """
      input do
        field :user_id, :string
        field :user_email, :string
      end

      output do
        field :contact, non_null(:contact)
      end

      resolve(&Resolvers.Account.add_contact/2)
    end
  end

  # Objects

  connection(node_type: :user)

  node object(:user) do
    field :email, non_null(:string)
    field :full_name, non_null(:string)
    field :inserted_at, non_null(:naive_datetime)

    connection field(:chat_members, node_type: :chat_member) do
      resolve(fn user, args, %{context: %{loader: loader, current_user: current_user}} ->
        if current_user.id == user.id do
          loader
          |> Dataloader.load(:commutox_repo, :chat_members, user)
          |> on_load(fn loader ->
            loader
            |> Dataloader.get(:commutox_repo, :chat_members, user)
            |> Connection.from_list(args)
          end)
        else
          {:error,
           Errors.forbidden(%{
             message: "User chat members are only available for the authenticated user."
           })}
        end
      end)
    end

    connection field(:messages, node_type: :message) do
      resolve(fn user, args, %{context: %{loader: loader, current_user: current_user}} ->
        if current_user.id == user.id do
          loader
          |> Dataloader.load(:commutox_repo, :messages, user)
          |> on_load(fn loader ->
            loader
            |> Dataloader.get(:commutox_repo, :messages, user)
            |> Connection.from_list(args)
          end)
        else
          {:error,
           Errors.forbidden(%{
             message: "User messages are only available for the authenticated user."
           })}
        end
      end)
    end

    connection field(:chats, node_type: :chat) do
      resolve(fn user, args, %{context: %{loader: loader, current_user: current_user}} ->
        if current_user.id == user.id do
          loader
          |> Dataloader.load(:commutox_repo, :chats, user)
          |> on_load(fn loader ->
            loader
            |> Dataloader.get(:commutox_repo, :chats, user)
            |> Connection.from_list(args)
          end)
        else
          {:error,
           Errors.forbidden(%{
             message: "User chats are only available for the authenticated user."
           })}
        end
      end)
    end
  end

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
