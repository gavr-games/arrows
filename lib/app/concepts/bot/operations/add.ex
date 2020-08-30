defmodule App.Bot.Operations.Add do
  use Monad.Operators
  import Monad.Result
  import App.Game.Helper
  alias App.{Game, Repo}
  alias App.User.Operations.Create, as: CreateUser
  require Logger

  def call(game_id, bot_difficulty) do
    result = success(game_id)
             ~>> fn game_id -> find_game(game_id) end
             ~>> fn game -> check_game(game) end
             ~>> fn game -> add_bot(game, bot_difficulty) end

    if success?(result) do
      success(unwrap!(result))
    else
      error(result.error)
    end
  end

  def find_game(game_id) do
    game = Repo.get!(Game, game_id)
    
    case game do
      nil -> error("Game was not found")
      game -> success(game)
    end
  end

  def check_game(game) do
    if game.status == game_status_code("new") and game.user2_id == nil do
      success(game)
    else
      error("Game already has second player or not new")
    end
  end

  def add_bot(game, bot_difficulty) do
    Faker.start()
    result = CreateUser.call(%{
      "name" => "#{Faker.Name.En.first_name()}Bot", 
      "password" => Faker.UUID.v4(), 
      "is_bot" => true,
      "bot_difficulty" => bot_difficulty
    })

    if success?(result) do
      bot = unwrap!(result)
      game = Game.changeset(game, %{user2_id: bot.id, status: game_status_code("running")})
      case Repo.update game do
        {:ok, game}       -> 
          AppWeb.Endpoint.broadcast "game:#{game.id}", "player2_joined", %{name: bot.name, id: bot.id}
          AppWeb.Endpoint.broadcast "game:#{game.id}", "start", %{}
          success(game)
        {:error, _} -> error("Unable to add Bot to the game")
      end
    else
      error("Cannot create Bot")
    end
  end

end