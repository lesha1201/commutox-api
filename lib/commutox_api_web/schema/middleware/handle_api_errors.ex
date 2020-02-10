defmodule CommutoxApiWeb.Schema.Middleware.HandleAPIErrors do
  @behaviour Absinthe.Middleware

  alias CommutoxApiWeb.Errors

  def call(resolution, _) do
    errors = Enum.flat_map(resolution.errors, &handle_error/1)

    %{resolution | errors: errors}
  end

  defp handle_error(%Ecto.Changeset{} = changeset) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, formatted_msg ->
          String.replace(formatted_msg, "%{#{key}}", to_string(value))
        end)
      end)
      |> CommutoxUtils.Map.to_camel_case()

    [
      Errors.invalid_input(%{
        extensions: %{
          details: errors
        }
      })
    ]
  end

  defp handle_error(error), do: [error]
end
