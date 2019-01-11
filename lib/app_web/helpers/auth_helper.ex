defmodule AppWeb.Helpers.Auth do
  alias App.User
  alias App.Repo

  def current_user(conn) do
    id = Plug.Conn.get_session(conn, :current_user)
    if id, do: Repo.get(User, id)
  end

  def is_logged_in(conn) do
    current_user(conn) != nil
  end
end