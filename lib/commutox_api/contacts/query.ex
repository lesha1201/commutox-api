defmodule CommutoxApi.Contacts.Query do
  @moduledoc """
  SQL queries related to Contacts context.
  """

  import Ecto.Query, warn: false

  alias CommutoxApi.Accounts.User
  alias CommutoxApi.Contacts.Contact
  alias CommutoxApi.Types, as: T

  @doc """
  Gets contacts for specified user.
  """
  @spec user_contacts(T.id()) :: Ecto.Query.t()
  def user_contacts(user_id) do
    from(c in Contact,
      join: u in User,
      on: u.id == c.user_sender_id or u.id == c.user_receiver_id,
      where: u.id == ^user_id,
      select: c
    )
  end
end
