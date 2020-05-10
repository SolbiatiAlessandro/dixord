defmodule Dixord.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string
      add :user_id, references(:users)
      add :chat_id, references(:chats)

      timestamps()
    end

    create unique_index(:messages, [:id])

    flush()

    default_user = Dixord.Accounts.get_user!(1)
    chat_welcome = Dixord.Messaging.get_chat!(1)
    chat_announcements = Dixord.Messaging.get_chat!(2)
    chat_faq = Dixord.Messaging.get_chat!(3)

    Dixord.Messaging.create_message(
      %{
        content: "You found Dixord, welcome!"
      },
      default_user,
      chat_welcome
    )

    Dixord.Messaging.create_message(
      %{
        content:
          "I just published a blog post about how I built Dixord, you can read it at http://www.lessand.ro/15/post."
      },
      default_user,
      chat_announcements
    )

    Dixord.Messaging.create_message(
      %{
        content:
          "The docs of Dixord are now online! You can read them at https://dixord.herokuapp.com/index.html"
      },
      default_user,
      chat_announcements
    )

    Dixord.Messaging.create_message(
      %{
        content: "Q: What does it mean that my temporary account is unclaimed? "
      },
      default_user,
      chat_faq
    )

    Dixord.Messaging.create_message(
      %{
        content:
          "A: All your messages will be saved, but you will lose access to your guest account FOREVER at every refresh of the page. If you want a permanent account go at https://dixord.herokuapp.com/registration/new (or just click on the orange box)"
      },
      default_user,
      chat_faq
    )
  end
end
