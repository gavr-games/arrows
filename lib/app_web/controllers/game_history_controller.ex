defmodule AppWeb.GameHistoryController do
  use AppWeb, :controller
  import Ecto.Query, only: [from: 2]
  alias App.{Repo, GameState, GameMove}
  require Logger

  plug AppWeb.Plugs.AiApiAllowed
  
  def list(conn, _params) do
    games = Repo.all(from gs in "game_states",
      distinct: true,
      order_by: [desc: :game_id],
      select: gs.game_id)
    render(conn, "list.html", games: games)
  end

  def show(conn, %{"game_id" => game_id}) do
    game_states = from(gs in GameState,
      where: (gs.game_id == ^game_id ),
      order_by: [asc: :turn],
      select: map(gs, [:turn, :state, :game_id])) |> Repo.all
    
    game_moves = from(gs in GameMove,
      where: (gs.game_id == ^game_id ),
      order_by: [asc: :turn],
      select: map(gs, [:turn, :move, :game_id])) |> Repo.all

    render(conn, "show.html", game_id: game_id, game_states: game_states, game_moves: game_moves)
  end
end