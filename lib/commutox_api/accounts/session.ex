defmodule CommutoxApi.Accounts.Session do
  alias CommutoxApi.Accounts

  def authenticate(args) do
    user = Accounts.get_user_by(email: String.downcase(args.email))

    case check_password(user, args) do
      true -> {:ok, user}
      _ -> {:error, "Invalid credentials."}
    end
  end

  defp check_password(user, %{password: password}) do
    case user do
      nil -> Argon2.no_user_verify()
      _ -> Argon2.verify_pass(password, user.password_hash)
    end
  end
end
