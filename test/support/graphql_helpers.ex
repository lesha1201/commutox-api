defmodule CommutoxApiWeb.GraphqlHelpers do
  use Phoenix.ConnTest

  import Absinthe.Relay.Node
  import Absinthe.Utils

  alias CommutoxApiWeb.Schema

  @endpoint CommutoxApiWeb.Endpoint

  def graphql_query(conn, options) do
    resp_conn =
      conn
      |> post("/api/graphql", build_query(options))

    Map.put(resp_conn, :resp_decoded, Jason.decode!(resp_conn.resp_body))
  end

  def build_query(options) do
    %{
      "operationName" => options[:operation_name],
      "query" => options[:query],
      "variables" => options[:variables]
    }
  end

  def build_query_fields(fields) do
    fields
    |> Enum.map(fn k -> k |> Atom.to_string() |> camelize(lower: true) end)
    |> Enum.join(" ")
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
    |> Map.put(:id, to_global_id(node_type, item.id, Schema))
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
end
