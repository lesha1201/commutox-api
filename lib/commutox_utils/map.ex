defmodule CommutoxUtils.Map do
  import Absinthe.Utils

  @doc """
  Converts snake case keys in map into camel case
  """

  def to_camel_case(%{} = map) do
    map
    |> Stream.map(fn {k, v} ->
      new_key = k |> to_string() |> camelize(lower: true)
      new_value = to_camel_case(v)

      {new_key, new_value}
    end)
    |> Enum.into(%{})
  end

  def to_camel_case(list) when is_list(list) do
    list
    |> Enum.map(fn value ->
      to_camel_case(value)
    end)
  end

  def to_camel_case(v), do: v
end
