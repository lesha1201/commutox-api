defmodule CommutoxUtils.Map do
  import Absinthe.Utils

  @doc """
  Converts snake case keys in map into camel case.
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

  @doc """
  Gets one of keys from map.

  ## Examples

      iex> get_one_of(%{a: 1, b: 2}, [:a, :b])
      {:a, 1}

      iex> get_one_of(%{a: nil, b: 2}, [:a, :b])
      {:b, 1}

      iex> get_one_of(%{}, [:a, :b])
      nil
  """
  @spec get_one_of(map, list) :: nil | {any, any}
  def get_one_of(_, []), do: nil

  def get_one_of(map, [key | keys]) do
    value = Map.get(map, key)

    if value != nil do
      {key, value}
    else
      get_one_of(map, keys)
    end
  end
end
