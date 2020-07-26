defmodule CommutoxApiWeb.Errors do
  @moduledoc """
  A module providing common errors returned by API.
  """

  @type t :: %{
          message: String.t(),
          extensions: %{
            code: String.t()
          }
        }

  @spec invalid_input :: t
  def invalid_input do
    %{
      message: "Validation error occured.",
      extensions: %{
        code: "INVALID_INPUT"
      }
    }
  end

  @spec invalid_input(map) :: t
  def invalid_input(%{} = extended) do
    DeepMerge.deep_merge(
      invalid_input(),
      extended
    )
  end

  @spec unauthenticated :: t
  def unauthenticated do
    %{
      message: "You must be authenticated.",
      extensions: %{
        code: "UNAUTHENTICATED"
      }
    }
  end

  @spec unauthenticated(map) :: t
  def unauthenticated(%{} = extended) do
    DeepMerge.deep_merge(
      unauthenticated(),
      extended
    )
  end

  @spec forbidden :: t
  def forbidden do
    %{
      message: "You don't have permissions to view it.",
      extensions: %{
        code: "FORBIDDEN"
      }
    }
  end

  @spec forbidden(map) :: t
  def forbidden(%{} = extended) do
    DeepMerge.deep_merge(
      forbidden(),
      extended
    )
  end

  @spec internal_error :: t
  def internal_error do
    %{
      message: "Something went wrong.",
      extensions: %{
        code: "INTERNAL"
      }
    }
  end

  @spec internal_error(map) :: t
  def internal_error(%{} = extended) do
    DeepMerge.deep_merge(
      internal_error(),
      extended
    )
  end
end
