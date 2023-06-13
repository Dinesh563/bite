defmodule BiteWeb.Router do
  use BiteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", BiteWeb do
    pipe_through :api

    get "/", PageController, :index
    post "/identity", IdentityController, :identity
  end

  # Other scopes may use custom stacks.
  # scope "/api", BiteWeb do
  #   pipe_through :api
  # end
end
