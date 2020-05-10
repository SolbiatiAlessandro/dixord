defmodule Dixord.Messaging.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field(:category, :string, default: "general")
    field(:name, :string)
    field(:description, :string)
    field(:public, :boolean, default: true, null: false)
    has_many(:messages, Dixord.Messaging.Message)

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :category, :public, :description])
    |> validate_required([:name, :category, :public])
  end
end
