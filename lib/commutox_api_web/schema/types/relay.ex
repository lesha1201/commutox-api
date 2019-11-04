defmodule CommutoxApiWeb.Schema.Types.Relay do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias CommutoxApi.{Accounts}

  object :relay_queries do
    node field do
      resolve(fn
        %{type: :user, id: id}, _ ->
          {:ok, Accounts.get_user(id)}

        _, _ ->
          {:error, "Invalid ID supplied."}
      end)
    end
  end

  node interface do
    resolve_type(fn
      %Accounts.User{}, _ ->
        :user

      _, _ ->
        nil
    end)
  end
end
