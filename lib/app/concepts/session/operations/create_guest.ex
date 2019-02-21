defmodule App.Session.Operations.CreateGuest do
  use Monad.Operators
  import Monad.Result
  alias App.User
  alias App.Session.Operations.Create, as: CreateSession
  alias App.User.Operations.Create, as: CreateUser

  def call(conn, user_params) do
    login_params = generate_password(user_params)
    result = success(login_params)
            ~>> fn user_params -> CreateUser.call(user_params) end
            ~>> fn _user -> CreateSession.call(conn, login_params) end

    if success?(result) do
      success(unwrap!(result))
    else
      error(result.error)
    end
  end

  def generate_password(user_params) do
    pass = :crypto.strong_rand_bytes(8) |> Base.url_encode64 |> binary_part(0, 8)
    Map.put(user_params, "password", pass)
  end
end