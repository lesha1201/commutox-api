defmodule CommutoxApiWeb.Schema.Types.Account do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias CommutoxApiWeb.Resolvers

  object :account_queries do
    @desc "Gets a list of all users"
    field :users, non_null(list_of(non_null(:user))) do
      resolve(&Resolvers.Account.users/3)
    end

    @desc "Gets a user by email."
    field :user, :user do
      arg(:email, non_null(:string))
      resolve(&Resolvers.Account.user/3)
    end
  end

  object :account_mutations do
    @desc "Creates a user"
    payload field(:create_user) do
      input do
        field :email, non_null(:string)
        field :full_name, non_null(:string)
        field :password, non_null(:string)
        field :password_confirmation, non_null(:string)
      end

      output do
        field :user, :user
      end

      resolve(&Resolvers.Account.create_user/2)
    end
  end

  node object(:user) do
    field :email, non_null(:string)
    field :full_name, non_null(:string)
  end
end
