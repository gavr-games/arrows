defmodule App.Game.Operations.Join do
  use Monad.Operators
  import Monad.Result
  import Ecto.Query, only: [from: 2]
  import App.Game.Helper
  alias App.{Game, User, Repo}
  require Logger

  def call(user_id) do
    result = success(user_id)
             ~>> fn user_id -> find_joined_game(user_id) end
             ~>> fn game -> find_new_game(user_id, game) end
             ~>> fn game -> create_game(user_id, game) end

    if success?(result) do
      success(unwrap!(result))
    else
      error(result.error)
    end
  end

  def find_joined_game(user_id) do
    game = from(g in Game,
      where: (g.status == ^game_status_code("running") and (g.user1_id == ^user_id or g.user2_id == ^user_id)) or (g.status == ^game_status_code("new") and g.user1_id == ^user_id ),
      limit: 1,
      select: map(g, [:id, :status, :user1_id, :user2_id])) |> Repo.all
    
    if length(game) == 1 do
      success(hd(game))
    else
      success(nil)
    end
  end

  def find_new_game(user_id, nil) do
    game = from(g in Game,
      where: g.status == ^game_status_code("new") and g.user1_id != ^user_id,
      limit: 1,
      select: map(g, [:id, :status, :user1_id, :user2_id])) |> Repo.all
    
    if length(game) == 1 do
      game = hd(game)
      game = Game.changeset(struct(Game, game), %{user2_id: user_id, status: game_status_code("running")})
      case Repo.update game do
        {:ok, game}       -> 
          user = Repo.get!(User, user_id)
          AppWeb.Endpoint.broadcast "game:#{game.id}", "player2_joined", %{name: user.name, id: user.id}
          AppWeb.Endpoint.broadcast "game:#{game.id}", "start", %{}
          success(game)
        {:error, changeset} -> error(changeset)
      end
    else
      success(nil)
    end
  end
  def find_new_game(_, game), do: success(game)

  def create_game(user_id, nil) do
    changeset = Game.changeset(%Game{}, %{status: game_status_code("new"), user1_id: user_id})

    case App.Repo.insert(changeset) do
      {:ok, game} ->
        success(game)
      {:error, changeset} ->
        error(changeset)
    end
  end
  def create_game(_, game), do: success(game)


end