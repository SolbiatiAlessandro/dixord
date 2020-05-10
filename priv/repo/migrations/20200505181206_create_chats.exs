defmodule Dixord.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :name, :string
      add :description, :string, default: ""
      add :category, :string, default: "general"
      add :public, :boolean, default: true, null: false

      timestamps()
    end

    flush()

    landing_chat = Dixord.Messaging.create_chat(%{name: "welcome", category: "general"})

    Dixord.Messaging.create_chat(%{
      name: "announcements",
      category: "information",
      description: "In this channel you can find all the latest updates on the Dixord project."
    })

    Dixord.Messaging.create_chat(%{
      name: "faq",
      category: "information",
      description:
        "In this channel you can FAQs about Dixord user experience. Feel free to ask anything here!"
    })
  end
end
