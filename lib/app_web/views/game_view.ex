defmodule AppWeb.GameView do
  use AppWeb, :view

  def status_text(status) do
    case status do
        0 -> "Waitting for start"
        1 -> "Running"
        2 -> "Finished"
    end
  end

  def player_name(user) do
    case user do
      nil -> ""
      u   -> u.name
    end
  end
end
