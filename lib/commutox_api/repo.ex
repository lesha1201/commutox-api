defmodule CommutoxApi.Repo do
  use Ecto.Repo,
    otp_app: :commutox_api,
    adapter: Ecto.Adapters.Postgres
end
