defmodule App.Bot.Operations.Move do
  use Monad.Operators
  import Monad.Result
  require Logger

  def call(board) do
    result = success(board)
             ~>> fn board -> call_bot(board) end
             ~>> fn move -> change_arrow(board, move) end

    if success?(result) do
      unwrap!(result)
    else
      board
    end
  end

  def call_bot(board) do
    result = HTTPoison.post "http://ai:8000", Poison.encode!(board), [{"Content-Type", "application/json"}]
    case result do
      {:error, e} -> error(e)
      {:ok, resp} -> success(Poison.decode!(resp.body))
    end
  end

  def change_arrow(board, move) do
    Logger.info inspect(move)
    if Map.has_key?(move, "direction") do
      success(put_in board[:arrows][move["y"]][move["x"]][:direction], move["direction"])
    else
      success(board)
    end
  end

end