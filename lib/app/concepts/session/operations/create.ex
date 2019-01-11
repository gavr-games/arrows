defmodule App.Session.Operations.Create do
  use Monad.Operators
  import Monad.Result
  alias App.User

  def call(conn, %{"name" => name, "password" => password}) do
    result = success(name)
             ~>> fn name -> user_exists(name) end
             ~>> fn user -> validate_password(user, password) end
             ~>> fn user -> create_session(conn, user) end

    if success?(result) do
      success(unwrap!(result))
    else
      error(result.error)
    end
  end

  def user_exists(name) do
    case App.Repo.get_by(User, name: name) do
      nil  -> error("User not found")
      user -> success(user)
    end
  end

  def validate_password(user, password) do
    case Comeonin.Argon2.checkpw(password, user.password) do
      false  -> error("User not found")
      true   -> success(user)
    end
  end

  def create_session(conn, user) do
    conn = Plug.Conn.put_session(conn, :current_user, user.id)
    success(conn)
  end
end