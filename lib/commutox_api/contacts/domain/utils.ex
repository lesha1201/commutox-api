defmodule CommutoxApi.Contacts.Domain.Utils do
  alias CommutoxApi.Accounts.{User}
  alias CommutoxApi.Contacts.{Contact}

  @doc """
  Check if the `contact` belongs to the `user` and retuns info
  about who user is: sender or receiver
  """
  @spec get_user_contact_type(User.t(), Contact.t()) ::
          {:ok, :receiver | :sender} | {:error, :not_owner}
  def get_user_contact_type(user, %{
        user_receiver_id: user_receiver_id,
        user_sender_id: user_sender_id
      }) do
    case user.id do
      ^user_receiver_id ->
        {:ok, :receiver}

      ^user_sender_id ->
        {:ok, :sender}

      _ ->
        {:error, :not_owner}
    end
  end
end
