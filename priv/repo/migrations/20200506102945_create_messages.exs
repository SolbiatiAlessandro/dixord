defmodule Dixord.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string
      add :user_id, references(:users)

      timestamps()
    end

    create unique_index(:messages, [:id])
  end
end
