defmodule CommutoxApiWeb.Schema.Types do
  use Absinthe.Schema.Notation

  alias CommutoxApiWeb.Schema.Types

  import_types(Absinthe.Type.Custom)
  import_types(Types.Account)
  import_types(Types.Chat)
  import_types(Types.Contact)
  import_types(Types.Relay)
end
