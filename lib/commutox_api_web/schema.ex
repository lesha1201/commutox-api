defmodule CommutoxApiWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types(CommutoxApiWeb.Schema.Types)

  query do
    import_fields(:relay_queries)
    import_fields(:account_queries)
    import_fields(:chat_queries)
    import_fields(:contact_queries)
  end

  mutation do
    import_fields(:account_mutations)
    import_fields(:chat_mutations)
    import_fields(:contact_mutations)
  end

  subscription do
    import_fields(:chat_subscriptions)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [CommutoxApiWeb.Schema.Middleware.HandleAPIErrors]
  end

  def middleware(middleware, _, _), do: middleware
end
