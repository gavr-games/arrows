defmodule AppWeb.Plugs.AiApiAllowed do
  use Phoenix.Controller

  def init(options) do
    options
  end

  def call(conn, _) do
    if System.get_env("MIX_ENV") == "dev" do
      conn
    else
      conn 
        |> put_status(:forbidden) 
        |> send_resp(403, "Forbidden")
        |> halt
    end
  end
end