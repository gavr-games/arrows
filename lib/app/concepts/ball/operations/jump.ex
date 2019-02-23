defmodule App.Ball.Operations.Jump do
  import App.Game.Helper
  alias App.Ball.Operations.{ Move, StartJump }

  def call(board, ball_id, player) do
    ball = board[:balls][ball_id]
    if ball[:player] != player do
      board
    else
      put_in board[:balls][ball_id], jump_ball(board[:balls][ball_id])
    end
  end

  defp jump_ball(ball) do
    case !ball[:jump] && ball[:jump_cooldown] == 0 && can_jump(ball) do
      true -> ball 
                |> Map.put(:want_jump, true)
      false -> ball
    end
  end

  defp can_jump(ball) do 
    #simulate jump to check if the ball is not too close to the borders
    ball = ball
      |> Move.call()
      |> StartJump.call()
    ball = Enum.reduce((0..game_jump_duration()), ball, fn _, b -> Move.call(b) end)
    ball[:x] >= 0 && ball[:y] >= 0 && ball[:x] <= max_x() && ball[:y] <= max_y()
  end

  defp max_x() do
    game_cols() * game_cell_width()
  end

  defp max_y() do
    game_rows() * game_cell_width()
  end
end