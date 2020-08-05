defmodule CommutoxApiWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  import Phoenix.ChannelTest

  alias Ecto.Adapters.SQL
  alias CommutoxApi.Accounts
  alias CommutoxApiWeb.UserSocket

  @endpoint CommutoxApiWeb.Endpoint

  using do
    quote do
      use Absinthe.Phoenix.SubscriptionTest, schema: CommutoxApiWeb.Schema

      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import CommutoxApiWeb.ChannelCase

      # The default endpoint for testing
      @endpoint CommutoxApiWeb.Endpoint
    end
  end

  setup tags do
    :ok = SQL.Sandbox.checkout(CommutoxApi.Repo)

    unless tags[:async] do
      SQL.Sandbox.mode(CommutoxApi.Repo, {:shared, self()})
    end

    :ok
  end

  def connect_to_socket(%Accounts.User{} = user) do
    case Accounts.Guardian.encode_and_sign(user) do
      {:ok, token, _} -> connect_to_socket(token)
      _ -> :error
    end
  end

  def connect_to_socket(token) do
    socket = socket(UserSocket)

    case UserSocket.connect(%{"token" => token}, socket) do
      {:ok, socket} -> socket
      _ -> :error
    end
  end
end
