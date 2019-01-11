defmodule App.Session.Operations.Destroy do
  use Monad.Operators
  import Monad.Result
  import Plug.Conn

  def call(conn) do
    conn = conn
          |> delete_session(:current_user)
          |> assign(:current_user, nil)
    success(conn)
  end
end