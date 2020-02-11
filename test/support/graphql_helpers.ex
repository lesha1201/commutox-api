defmodule CommutoxApiWeb.GraphqlHelpers do
  use Phoenix.ConnTest

  import Absinthe.Utils

  alias Absinthe.Relay.Node, as: Relay
  alias CommutoxApiWeb.Schema

  @endpoint CommutoxApiWeb.Endpoint

  def graphql_query(conn, options) do
    resp_conn =
      conn
      |> post("/api/graphql", build_query(options))

    Map.put(resp_conn, :resp_decoded, Jason.decode!(resp_conn.resp_body))
  end

  def build_query(options) do
    processed_variables = options[:variables] |> process_variables()

    %{
      "operationName" => options[:operation_name],
      "query" => options[:query],
      "variables" => processed_variables
    }
  end

  def build_query_fields(fields) do
    fields
    |> Enum.map(fn k -> k |> Atom.to_string() |> camelize(lower: true) end)
    |> Enum.join(" ")
  end

  @doc """
  Converts snake case keys in map into camel case
  """
  def process_variables(variables) do
    CommutoxUtils.Map.to_camel_case(variables)
  end

  @doc """
  Binded Absinthe relay's `to_global_id` to `Schema`
  """
  def to_global_id(node_type, source_id) do
    Relay.to_global_id(node_type, source_id, Schema)
  end

  @doc """
  Takes `item` from database response, takes its keys (`keys_to_take`)
  and converts it to relay-graphql response (id -> to opaque global string)
  """
  def to_response_format(item, node_type, keys_to_take \\ []) do
    keys_to_take = [:id | keys_to_take] |> Enum.dedup()

    item
    |> Map.from_struct()
    |> Map.take(keys_to_take)
    |> Map.put(:id, to_global_id(node_type, item.id))
    |> Enum.map(fn {k, v} -> {k |> Atom.to_string() |> camelize(lower: true), v} end)
    |> Enum.into(%{})
  end

  def from_response_format(resp) when is_map(resp) do
    resp
    |> Enum.map(fn {k, v} ->
      {
        k |> Macro.underscore() |> String.to_atom(),
        if(is_map(v), do: from_response_format(v), else: v)
      }
    end)
    |> Enum.into(%{})
  end

  def has_connection_with(response, target_name, connection_name)
      when is_binary(target_name) and is_binary(connection_name) do
    targets = get_in(response, ["data", target_name, "edges"])

    connections =
      get_in(targets, [
        fn :get, data, next -> Enum.map(data, next) end,
        "node",
        connection_name,
        "edges"
      ])
      |> Enum.flat_map(& &1)

    length(targets) > 0 && length(connections) > 0
  end

  def has_connection_with(_, _, _) do
    raise ArgumentError, message: "target_name, connection_name should be string"
  end
end
