defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_token
  end

  defp put_user_token(conn, _) do
    case get_session(conn, :current_user) do
      nil -> conn
      user_id -> 
        token = Phoenix.Token.sign(conn, "user socket", user_id)
        assign(conn, :user_token, token)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :index
    get  "/login", UserController, :login
    post  "/auth", UserController, :authenticate
    post  "/auth_guest", UserController, :authenticate_guest
    get  "/logout", UserController, :logout
    get "/signup", UserController, :new
    post "/register", UserController, :create

    get "/games/join", GameController, :join
    resources "/games", GameController do
      get "/play", GameController, :play
      get "/exit", GameController, :exit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
