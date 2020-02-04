defmodule CommutoxApiWeb.ConnHelpers do
  import Plug.Conn

  alias CommutoxApi.Accounts

  def authenticate_with_jwt(conn, user) do
    {:ok, jwt_token, _} = Accounts.Guardian.encode_and_sign(user)
    put_req_header(conn, "authorization", "Bearer #{jwt_token}")
  end
end
