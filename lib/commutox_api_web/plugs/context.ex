defmodule CommutoxApiWeb.Plugs.Context do
  @behaviour Plug

  import Plug.Conn

  alias CommutoxApi.{Accounts}
  alias CommutoxApi.Accounts.User

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    current_user = get_current_user(conn)
    loader = create_dataloader()

    case current_user do
      %User{} -> %{current_user: current_user, loader: loader}
      _ -> %{loader: loader}
    end
  end

  defp get_current_user(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Accounts.Guardian.decode_and_verify(token),
         {:ok, user} <- Accounts.Guardian.resource_from_claims(claims) do
      user
    else
      _ -> nil
    end
  end

  defp create_dataloader() do
    Dataloader.new()
    |> Dataloader.add_source(:commutox_repo, Dataloader.Ecto.new(CommutoxApi.Repo))
  end
end
