defmodule Dixord.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs \\ %{}) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
  end

  def get_messages(limit \\ 20) do
    Dixord.Repo.all(Dixord.Message, limit: limit)
  end

  def create_message(message_params) do
	Dixord.Message.changeset(%Dixord.Message{}, message_params)
	|> Dixord.Repo.insert!()
  end

  def change_message do
	Dixord.Message.changeset(%Dixord.Message{})
  end

  def change_message(changeset, changes) do
	Message.changeset(changeset, changes)
  end
end
