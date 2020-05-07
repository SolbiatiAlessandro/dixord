defmodule Dixord.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  alias Dixord.Accounts.User

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :username, :string
      add :password_hash, :string

      add :claimed, :boolean, default: false, null: false
      add :profile_picture_url, :string, default: "https://discordapp.com/assets/6debd47ed13483642cf09e832ed0bc1b.png"

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
