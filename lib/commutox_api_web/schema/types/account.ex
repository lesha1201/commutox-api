defmodule CommutoxApiWeb.Schema.Types.Account do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Absinthe.Relay.Connection
  alias CommutoxApiWeb.Errors
  alias CommutoxApiWeb.Resolvers

  # Queries

  object :account_queries do
    @desc "Gets a list of all users."
    connection field(:users, node_type: :user) do
      resolve(&Resolvers.Account.list_users/2)
    end

    @desc "Gets a user by email."
    field :user, :user do
      arg(:email, non_null(:string))
      resolve(&Resolvers.Account.user/3)
    end
  end

  # Mutations

  object :account_mutations do
    @desc "Signs up a user."
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

      middleware(&put_auth_token/2)
    end

    @desc "Signs in a user."
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

      middleware(&put_auth_token/2)
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

  # Functions

  defp put_auth_token(resolution, _) do
    with %{value: %{token: token}} <- resolution do
      Map.update!(resolution, :context, fn ctx ->
        Map.put(ctx, :auth_token, token)
      end)
    end
  end
end
