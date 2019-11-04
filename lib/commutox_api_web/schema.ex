defmodule CommutoxApiWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types(CommutoxApiWeb.Schema.Types)

  query do
    import_fields(:relay_queries)
    import_fields(:account_queries)
  end

  mutation do
    import_fields(:account_mutations)
  end
end
