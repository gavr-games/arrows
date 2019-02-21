defmodule AppWeb.UserController do
  use AppWeb, :controller
  import Monad.Result
  alias App.User
  alias App.User.Operations.{Create}
  alias App.Session.Operations.Destroy, as: DestroySession
  alias App.Session.Operations.Create, as: CreateSession
  alias App.Session.Operations.CreateGuest, as: CreateGuestSession

  plug AppWeb.Plugs.Authenticated when action in [:logout]
  plug AppWeb.Plugs.NotAuthenticated when action in [:new, :create, :login, :authenticate]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    result = Create.call(user_params)

    if success?(result) do
      conn
      |> put_flash(:info, "Thank you for signup")
      |> redirect(to: "/")
    else
      changeset = result.error
      render(conn, "new.html", changeset: changeset)
    end
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def logout(conn, _params) do
    result = DestroySession.call(conn)

   if success?(result) do
     conn = unwrap!(result)
     conn
     |> put_flash(:info, "You are logged out")
     |> redirect(to: "/")
   else
     conn
     |> put_flash(:error, result.error)
     |> redirect(to: "/")
   end
  end

  def authenticate(conn, login_params) do
    result = CreateSession.call(conn, login_params)

    if success?(result) do
     conn = unwrap!(result)
     conn
     |> put_flash(:info, "Welcome!")
     |> redirect(to: "/")
    else
     conn
     |> put_flash(:error, result.error)
     |> render("login.html")
    end
  end

  def authenticate_guest(conn, login_params) do
    result = CreateGuestSession.call(conn, login_params)

    if success?(result) do
     conn = unwrap!(result)
     conn
     |> put_flash(:info, "Welcome!")
     |> redirect(to: "/")
    else
     conn
     |> put_flash(:error, "Name has already been taken!")
     |> redirect(to: "/")
    end
  end
end