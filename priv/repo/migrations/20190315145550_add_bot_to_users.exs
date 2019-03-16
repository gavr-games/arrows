defmodule App.Repo.Migrations.AddBotToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_bot, :boolean
    end
  end
end
