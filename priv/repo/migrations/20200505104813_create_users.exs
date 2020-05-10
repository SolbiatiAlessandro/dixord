defmodule Dixord.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  alias Dixord.Accounts.User

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :username, :string
      add :password_hash, :string

      add :claimed, :boolean, default: true, null: false

      add :profile_picture_url, :string,
        default: "https://discordapp.com/assets/6debd47ed13483642cf09e832ed0bc1b.png"

      timestamps()
    end

    create unique_index(:users, [:email])

    flush()

    # TODO: https://github.com/SolbiatiAlessandro/dixord/issues/8
    alex_user =
      Dixord.Accounts.create_user(%{
        username: "Alessandro",
        email: "alexsolbiati@hotmail.it",
        password: "unsafe_password",
        password_confirmation: "unsafe_password",
        profile_picture_url:
          "https://avatars2.githubusercontent.com/u/20618047?s=460&u=5bce55a9214223d5d200e2d858e3c14559c88ebf&v=4",
        claimed: true
      })
  end
end
