defmodule CommutoxApiWeb.Schema.Types.Chat do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, on_load: 2]

  alias Absinthe.Relay.Connection
  alias CommutoxApiWeb.Resolvers

  object :chat_queries do
    @desc "Gets a list of all chats current user can see"
    connection field(:chats, node_type: :chat) do
      resolve(&Resolvers.Chat.list_chats/2)
    end

    @desc "Gets a list of all chat members current user can see"
    connection field(:chat_members, node_type: :chat_member) do
      resolve(&Resolvers.Chat.list_chat_members/2)
    end

    @desc "Gets a list of all messages current user can see"
    connection field(:messages, node_type: :message) do
      resolve(&Resolvers.Chat.list_messages/2)
    end
  end

  object :chat_mutations do
  end

  connection(node_type: :chat_member)

  node object(:chat_member) do
    field :last_read_at, :naive_datetime
    field :inserted_at, non_null(:naive_datetime)
    field :chat, :chat, resolve: dataloader(:commutox_repo)
    field :user, :user, resolve: dataloader(:commutox_repo)
  end

  connection(node_type: :chat)

  node object(:chat) do
    field :inserted_at, non_null(:naive_datetime)

    connection field(:members, node_type: :chat_member) do
      resolve(fn chat, args, %{context: %{loader: loader}} ->
        loader
        |> Dataloader.load(:commutox_repo, :members, chat)
        |> on_load(fn loader ->
          loader
          |> Dataloader.get(:commutox_repo, :members, chat)
          |> Connection.from_list(args)
        end)
      end)
    end

    connection field(:users, node_type: :user) do
      resolve(fn chat, args, %{context: %{loader: loader}} ->
        loader
        |> Dataloader.load(:commutox_repo, :users, chat)
        |> on_load(fn loader ->
          loader
          |> Dataloader.get(:commutox_repo, :users, chat)
          |> Connection.from_list(args)
        end)
      end)
    end

    connection field(:messages, node_type: :message) do
      resolve(fn chat, args, %{context: %{loader: loader}} ->
        loader
        |> Dataloader.load(:commutox_repo, :messages, chat)
        |> on_load(fn loader ->
          loader
          |> Dataloader.get(:commutox_repo, :messages, chat)
          |> Connection.from_list(args)
        end)
      end)
    end
  end

  connection(node_type: :message)

  node object(:message) do
    field :text, :string
    field :inserted_at, non_null(:naive_datetime)
    field :chat, :chat, resolve: dataloader(:commutox_repo)
    field :user, :user, resolve: dataloader(:commutox_repo)
  end
end
