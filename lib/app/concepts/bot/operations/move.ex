defmodule App.Bot.Operations.Move do
  use Monad.Operators
  import Monad.Result
  require Logger

  def call(board) do
    result = success(board)
             ~>> fn board -> change_arrows(board) end

    #result = success(board)
    #         ~>> fn board -> call_bot(board) end
    #         ~>> fn move -> change_arrow(board, move) end

    if success?(result) do
      unwrap!(result)
    else
      board
    end
  end

  def change_arrows(board) do
    coords = for i <- 0..board[:config][:cols], j <- 0..board[:config][:rows], do:  {i * board[:config][:cell_width], j * board[:config][:cell_width]}
    arrows = coords
      |> Enum.map(fn {x, y} -> board[:arrows][x][y] end)
      |> Enum.filter(fn arrow -> 
          arrow[:player] == board[:player2] # filter arrows, which belong to bot (player2)
         end)
      |> Enum.map(fn arrow -> change_arrow(board, arrow) end)
      |> Enum.reduce(board[:arrows], fn arrow, acc ->
          put_in(acc[arrow[:y]][arrow[:x]], arrow)
         end)
    board = Map.put(board, :arrows, arrows)
    success(board)
  end

  def change_arrow(board, arrow) do
    dirs = possible_directions(board, arrow)
    arrow = Map.put(arrow, :direction, Enum.random(dirs))
    arrow
  end

  def possible_directions(board, arrow) do
    [0, 1, 2, 3] # ^ > \/ <
    |> filter_up(board, arrow)
    |> filter_right(board, arrow)
    |> filter_down(board, arrow)
    |> filter_left(board, arrow)
  end

  def filter_up(dirs, board, arrow) do
    cond do
      arrow[:y] == 0 ->
        Enum.filter(dirs, fn dir -> dir != 0 end)
      true ->
        dirs
    end
  end

  def filter_right(dirs, board, arrow) do
    cond do
      arrow[:x] == board[:config][:cols] * board[:config][:cell_width] ->
        Enum.filter(dirs, fn dir -> dir != 1 end)
      true ->
        dirs
    end
  end

  def filter_down(dirs, board, arrow) do
    cond do
      arrow[:y] == board[:config][:rows] * board[:config][:cell_width] ->
        Enum.filter(dirs, fn dir -> dir != 2 end)
      true ->
        dirs
    end
  end

  def filter_left(dirs, board, arrow) do
    cond do
      arrow[:x] == 0 ->
        Enum.filter(dirs, fn dir -> dir != 3 end)
      true ->
        dirs
    end
  end

  # Call python AI bot

  #def call_bot(board) do
  #  result = HTTPoison.post "http://ai:8000", Poison.encode!(board), [{"Content-Type", "application/json"}]
  #  case result do
  #    {:error, e} -> error(e)
  #    {:ok, resp} -> success(Poison.decode!(resp.body))
  #  end
  #end

  #def change_arrow(board, move) do
  #  Logger.info inspect(move)
  #  if Map.has_key?(move, "direction") do
  #    success(put_in board[:arrows][move["y"]][move["x"]][:direction], move["direction"])
  #  else
  #    success(board)
  #  end
  #end

end