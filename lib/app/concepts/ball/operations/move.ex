defmodule App.Ball.Operations.Move do
  import App.Game.Helper

  def call(ball) do
    {new_x, new_y} = case ball[:direction] do
      0 -> {ball[:x], ball[:y] - ball[:speed]}
      1 -> {ball[:x] + ball[:speed], ball[:y]}
      2 -> {ball[:x], ball[:y] + ball[:speed]}
      3 -> {ball[:x] - ball[:speed], ball[:y]}
      _ -> {ball[:x], ball[:y] - ball[:speed]}
    end
    ball
      |> Map.put(:x, new_x)
      |> Map.put(:y, new_y)
      |> decrease_jump_cooldown()
  end

  defp decrease_jump_cooldown(ball) do
    case ball[:jump_cooldown] do
      0 -> ball
      cooldown -> Map.put(ball, :jump_cooldown, cooldown - 1)
    end
  end
  
end