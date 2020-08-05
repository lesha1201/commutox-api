defmodule CommutoxApiWeb.Channels.UserSocketTest do
  use CommutoxApiWeb.ChannelCase, async: true

  import CommutoxApi.Fixtures

  alias CommutoxApiWeb.UserSocket

  describe "connect/2" do
    setup do
      socket = socket(UserSocket)

      {:ok, %{socket: socket}}
    end

    test "returns socket with set options when user is authenticated", %{socket: socket} do
      {:ok, %{user: user}} = user_fixture()
      {:ok, jwt_token, _} = CommutoxApi.Accounts.Guardian.encode_and_sign(user)

      params = %{
        "token" => jwt_token
      }

      {:ok,
       %Phoenix.Socket{assigns: %{absinthe: %{opts: [context: %{current_user: current_user}]}}}} =
        UserSocket.connect(params, socket)

      assert current_user.id == user.id
    end

    test "returns error when user isn't authenticated", %{socket: socket} do
      assert UserSocket.connect(
               %{
                 "token" => "invalid token"
               },
               socket
             ) == :error

      assert UserSocket.connect(
               %{},
               socket
             ) == :error
    end
  end
end
