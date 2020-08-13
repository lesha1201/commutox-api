defmodule CommutoxApiWeb.Router do
  use CommutoxApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    cors_options =
      case Application.fetch_env(:commutox_api, :cors) do
        {:ok, value} -> value
        :error -> nil
      end

    if cors_options do
      plug CORSPlug, cors_options
    end

    plug :accepts, ["json"]
    plug CommutoxApiWeb.Plugs.Context
  end

  scope "/api" do
    pipe_through :api

    forward("/graphql", Absinthe.Plug,
      schema: CommutoxApiWeb.Schema,
      before_send: {__MODULE__, :absinthe_before_send}
    )

    if Mix.env() == :dev do
      forward("/graphiql", Absinthe.Plug.GraphiQL,
        schema: CommutoxApiWeb.Schema,
        socket: CommutoxApiWeb.UserSocket,
        before_send: {__MODULE__, :absinthe_before_send}
      )
    end
  end

  def absinthe_before_send(conn, %Absinthe.Blueprint{} = blueprint) do
    auth_token = blueprint.execution.context[:auth_token]

    if auth_token do
      put_resp_cookie(conn, "_commutox_api_auth_token", auth_token,
        http_only: true,
        same_site: "Lax",
        max_age: 604_800
      )
    else
      conn
    end
  end

  def absinthe_before_send(conn, _) do
    conn
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CommutoxApiWeb.Telemetry
    end
  end
end
