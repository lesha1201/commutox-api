defmodule CommutoxApiWeb.Plugs.Context do
  @behaviour Plug

  import Plug.Conn

  alias CommutoxApi.Accounts
  alias CommutoxApi.Accounts.User

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(%Plug.Conn{} = conn) do
    current_user = get_current_user(conn)
    build_context(%{current_user: current_user})
  end

  def build_context(%{current_user: current_user}) do
    loader = create_dataloader()

    case current_user do
      %User{} -> %{current_user: current_user, loader: loader}
      _ -> %{loader: loader}
    end
  end

  defp get_current_user(conn) do
    token = get_auth_token(conn)

    with true <- is_binary(token),
         {:ok, user, _claims} <- Accounts.Guardian.resource_from_token(token) do
      user
    else
      _ -> nil
    end
  end

  defp get_auth_token(conn) do
    conn = fetch_cookies(conn)
    token = conn.cookies["_commutox_api_auth_token"]

    if token do
      token
    else
      get_authorization_header_token(conn)
    end
  end

  defp get_authorization_header_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      token
    else
      _ -> nil
    end
  end

  defp create_dataloader do
    Dataloader.new()
    |> Dataloader.add_source(:commutox_repo, Dataloader.Ecto.new(CommutoxApi.Repo))
  end
end
