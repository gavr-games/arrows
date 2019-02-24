defmodule App.Ball.Operations.StartJump do
  import App.Game.Helper

  def call(ball) do
    case ball[:want_jump] do
      false -> ball
      true -> ball
              |> Map.put(:want_jump, false)
              |> Map.put(:jump, true)
              |> Map.put(:speed, game_jump_speed())
              |> Map.put(:jump_cooldown, game_jump_cooldown())
    end
  end
end