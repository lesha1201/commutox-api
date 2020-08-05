defmodule CommutoxApiWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: CommutoxApiWeb.Schema

  alias CommutoxApi.Accounts

  def connect(%{"token" => token}, socket) do
    case Accounts.Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        socket_with_opts =
          socket
          |> put_absinthe_options(user)
          |> assign(:current_user, user)

        {:ok, socket_with_opts}

      {:error, _} ->
        :error
    end
  end

  def connect(_, _) do
    :error
  end

  def id(_socket), do: nil

  defp put_absinthe_options(socket, user) do
    Absinthe.Phoenix.Socket.put_options(socket,
      context: CommutoxApiWeb.Plugs.Context.build_context(%{current_user: user})
    )
  end
end
