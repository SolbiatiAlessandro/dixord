defmodule Dixord.Accounts.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  import Ecto.Changeset
  alias Dixord.Accounts.User

  schema "users" do
    field :claimed, :boolean, default: true
    field :profile_picture_url, :string, default: "https://discordapp.com/assets/6debd47ed13483642cf09e832ed0bc1b.png"
    field :username, :string
    has_many :messages, Dixord.Messaging.Message

    pow_user_fields()
    timestamps()
  end

  @doc false
  def default_profile_picture() do
    Application.fetch_env!(:dixord, :guests_profile_images) 
      |> Map.values() 
      |> Enum.random()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> cast(attrs, [:username, :claimed, :profile_picture_url])
    |> validate_required([:username, :claimed, :profile_picture_url])
    |> unique_constraint(:username)
  end

  @doc false
  def changeset_without_pow(user, attrs) do
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
