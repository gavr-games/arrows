defmodule App.Board.Operations.Init do
  import App.Game.Helper
  require Logger

  def call(game, config \\ nil) do
    config = case config do
      nil -> %{
        cols: game_cols(),
        rows: game_rows(),
        base_health: game_base_health(),
        cell_width: game_cell_width(),
        ball_speed: game_ball_speed(),
        new_ball_period: game_new_ball_period()
      }
      _ -> config
    end

    %{
      config: config,
      player1: game.user1_id,
      player2: game.user2_id,
      turn: 0,
      arrows: prepare_arrows(game, config, config[:rows], config[:cols], %{}),
      balls: %{},
      bases: %{
        0 => %{
          x: 0,
          y: 0,
          health: config[:base_health],
          player: game.user1_id
        },
        1 => %{
          x: config[:cols] * config[:cell_width],
          y: config[:rows] * config[:cell_width],
          health: config[:base_health],
          player: game.user2_id
        }
      }
    }
  end

  defp prepare_arrows(game, config, 0, cols, arrows), do: Map.put(arrows, 0, prepare_arrows_row(game, config, 0, cols, %{}))
  defp prepare_arrows(game, config, row, cols, arrows) do 
    prepare_arrows(game, config, row - 1, cols, Map.put(arrows, row * config[:cell_width], prepare_arrows_row(game, config, row, cols, %{})))
  end


  defp prepare_arrows_row(game, config, row, 0, arrows) do
    arrow = prepare_arrow(game, config, row, 0)
    Map.put(arrows, 0, arrow)
  end
  defp prepare_arrows_row(game, config, row, col, arrows) do
    arrow = prepare_arrow(game, config, row, col)
    prepare_arrows_row(game, config, row, col - 1, Map.put(arrows, col * config[:cell_width], arrow))
  end

  defp prepare_arrow(game, config, row, col) do
    {p, d} = cond do
      row == 0 && col == 0 -> {game.user1_id, 1}
      row == config[:rows] && col == config[:cols] -> {game.user2_id, 3}
      true -> {nil, nil}
    end
    %{
      x: col * config[:cell_width],
      y: row * config[:cell_width],
      player: p,
      direction: d
    }
  end
end