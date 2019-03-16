defmodule App.Cell.Operations.CountPerPlayer do
  require Logger

  def call(player, board) do
    coords = for i <- 0..9, j <- 0..9, do:  {i, j}
    coords
      |> Enum.map(fn {x, y} -> check_cell(x, y, player, board) end)
      |> Enum.sum()
  end

  defp check_cell(x, y, player, board) do
    arrow1 = board[:arrows][x * board[:config][:cell_width]][y * board[:config][:cell_width]][:player] == player
    arrow2 = board[:arrows][(x + 1) * board[:config][:cell_width]][y * board[:config][:cell_width]][:player] == player
    arrow3 = board[:arrows][(x + 1) * board[:config][:cell_width]][(y + 1) * board[:config][:cell_width]][:player] == player
    arrow4 = board[:arrows][x * board[:config][:cell_width]][(y + 1) * board[:config][:cell_width]][:player] == player
    cond do
      arrow1 && arrow2 && arrow3 && arrow4 -> 1
      true -> 0
    end
  end
end