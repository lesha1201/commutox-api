defmodule CommutoxApiWeb.Router do
  use CommutoxApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CommutoxApiWeb.Plugs.Context
  end

  scope "/api" do
    pipe_through :api

    forward("/graphql", Absinthe.Plug, schema: CommutoxApiWeb.Schema)

    if Mix.env() == :dev do
      forward("/graphiql", Absinthe.Plug.GraphiQL, schema: CommutoxApiWeb.Schema)
    end
  end
end
