defmodule Dixord.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :claimed, :boolean, default: false
    field :profile_picture_url, :string
    field :username, :string
    has_many :messages, Dixord.Messaging.Message

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :claimed, :profile_picture_url])
    |> validate_required([:username, :claimed, :profile_picture_url])
    |> unique_constraint(:username)
  end

  @doc false
  def populate(data) do
    %Dixord.Accounts.User{
      id: data.id,
      username: data.username,
      profile_picture_url: data.profile_picture_url,
    }
  end

end
