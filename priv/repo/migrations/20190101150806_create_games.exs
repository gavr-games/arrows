defmodule App.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :status, :integer
      add :state, :map
      add :user1_id, references(:users, on_delete: :delete_all)
      add :user2_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

  end
end
