defmodule App.Game.Operations.Exit do
  use Monad.Operators
  import Monad.Result
  import Ecto.Query, only: [from: 2]
  import App.Game.Helper
  alias App.Game
  alias App.Repo

  def call(game_id) do
    result = success(game_id)
             ~>> fn game_id -> find_game(game_id) end
             ~>> fn game -> finish_game(game) end

    if success?(result) do
      success(result.value)
    else
      error(result.error)
    end
  end

  def find_game(game_id) do
    game = from(g in Game,
      where: g.id == ^game_id,
      limit: 1,
      select: map(g, [:id, :status, :user1_id, :user2_id])) |> Repo.all
    
    if length(game) == 1 do
      success(hd(game))
    else
      error("Game not found")
    end
  end

  def finish_game(game) do
    game = Ecto.Changeset.change struct(Game, game), status: game_status_code("finished")
    case Repo.update game do
      {:ok, game}       -> 
        AppWeb.Endpoint.broadcast "game:#{game.id}", "finish", %{}
        success(game)
      {:error, changeset} -> error(changeset)
    end
  end
end