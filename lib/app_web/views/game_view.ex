defmodule AppWeb.GameView do
  use AppWeb, :view

  def status_text(status) do
    case status do
        0 -> "Waitting for another player"
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

  def add_bot_link(conn, game) do
    case game.user2 do
      nil -> link("Add bot", to: Routes.game_game_path(conn, :exit, game.id), class: "btn btn-info btn-lg card-link", id: "add-bot")
      _   -> ""
    end
  end
end
