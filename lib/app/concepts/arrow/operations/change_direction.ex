defmodule App.Arrow.Operations.ChangeDirection do
  require Logger

  def call(x, y, player, board) do
    arrow = board[:arrows][y][x]
    if arrow[:player] != player do
      board
    else
      put_in board[:arrows][y][x][:direction], next_direction(x, y, board[:arrows][y][x][:direction], board)
    end
  end

  defp next_direction(x, y, direction, board) do
    d = direction + 1
    d = case d do
      4 -> 0
      _ -> d
    end
    cond do
      d == 0 && y == 0 -> next_direction(x, y, d, board)
      d == 3 && x == 0 -> next_direction(x, y, d, board)
      d == 1 && x == board[:config][:cols] * board[:config][:cell_width] -> next_direction(x, y, d, board)
      d == 2 && y == board[:config][:rows] * board[:config][:cell_width] -> next_direction(x, y, d, board)
      true -> d
    end
  end
end