defmodule App.Repo.Migrations.AddGameHistories do
  use Ecto.Migration

  def change do
    create table(:game_states) do
      add :game_id, references(:games, on_delete: :delete_all)
      add :turn, :integer
      add :state, :map

      timestamps()
    end

    create table(:game_moves) do
      add :game_id, references(:games, on_delete: :delete_all)
      add :turn, :integer
      add :move, :map

      timestamps()
    end
  end
end
