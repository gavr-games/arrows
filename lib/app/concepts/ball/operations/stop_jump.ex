defmodule App.Ball.Operations.StopJump do
  import App.Game.Helper

  def call(ball) do
    case ball[:jump] && game_jump_cooldown() - ball[:jump_cooldown]  == game_jump_duration() do
      false -> ball
      true -> ball
              |> Map.put(:jump, false)
              |> Map.put(:speed, game_ball_speed())
    end
  end
end