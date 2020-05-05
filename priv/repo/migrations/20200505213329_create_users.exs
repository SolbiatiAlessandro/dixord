defmodule Dixord.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :claimed, :boolean, default: false, null: false
      add :profile_picture_url, :string

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
