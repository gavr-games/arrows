defmodule App.Repo.Migrations.AddBotDifficultyToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :bot_difficulty, :string
    end
  end
end
