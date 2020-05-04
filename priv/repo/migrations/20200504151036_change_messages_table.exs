defmodule Dixord.Repo.Migrations.ChangeMessagesTable do
  use Ecto.Migration

  def change do
    rename table("messages"), :name, to: :author_name
    alter table("messages") do 
      add :profile_picture_url, :string
    end
  end
end
