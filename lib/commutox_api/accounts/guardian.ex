defmodule CommutoxApi.Accounts.Guardian do
  use Guardian, otp_app: :commutox_api

  alias CommutoxApi.Accounts

  def subject_for_token(%Accounts.User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, "Subject for token should be User."}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, "User not found."}
      user -> {:ok, user}
    end
  end
end
