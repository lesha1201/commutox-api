defmodule CommutoxApiWeb.Errors do
  @moduledoc """
  A module providing common errors returned by API.
  """

  def invalid_input do
    %{
      message: "Validation error occured.",
      extensions: %{
        code: "INVALID_INPUT"
      }
    }
  end

  def invalid_input(%{} = extended) do
    DeepMerge.deep_merge(
      invalid_input(),
      extended
    )
  end

  def unauthorized do
    %{
      message: "You should be authorized.",
      extensions: %{
        code: "UNAUTHORIZED"
      }
    }
  end

  def unauthorized(%{} = extended) do
    DeepMerge.deep_merge(
      unauthorized(),
      extended
    )
  end

  def forbidden do
    %{
      message: "You don't have permissions to view it.",
      extensions: %{
        code: "FORBIDDEN"
      }
    }
  end

  def forbidden(%{} = extended) do
    DeepMerge.deep_merge(
      forbidden(),
      extended
    )
  end
end
