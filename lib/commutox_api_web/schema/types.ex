defmodule CommutoxApiWeb.Schema.Types do
  use Absinthe.Schema.Notation

  alias CommutoxApiWeb.Schema.Types

  import_types(Types.Relay)
  import_types(Types.Account)
end
