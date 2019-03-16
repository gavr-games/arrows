defmodule AppWeb.GameController do
  use AppWeb, :controller
  import Monad.Result
  import AppWeb.Router.Helpers
  alias App.Game.Operations.{Join, Exit}
  alias App.Repo
  alias App.Game

  plug AppWeb.Plugs.Authenticated when action in [:join, :play]

  def join(conn, _params) do
    result = Join.call(current_user(conn).id)

    if success?(result) do
      game = result.value
      conn
      |> redirect(to: game_game_path(conn, :play, game.id))
    else
      conn
      |> put_flash(:error, "Cannot join game")
      |> redirect(to: "/")
    end
  end

  def play(conn, %{"game_id" => game_id}) do
    game = Repo.get!(Game, game_id)
      |> Repo.preload([:user1, :user2])
    App.Game.Server.create(game)
    render(conn, "play.html", game: game)
  end

  def exit(conn, %{"game_id" => game_id}) do
    result = Exit.call(game_id)

    if success?(result) do
      conn
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:error, "Error exiting game")
      |> redirect(to: "/")
    end
  end
end