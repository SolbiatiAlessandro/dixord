defmodule Dixord.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias Dixord.Repo
  require UUID

  alias Dixord.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
    |> Repo.preload([:messages])
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id) |> Repo.preload([:messages])
  def get_user_without_preload!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  """
  Creates a guest user with standard params

  We put them in the database so that the messaging
  logic can just pass around user ids and doesn't need
  to know whether these are users or guests.

  Guests user have a 'fake' email of the form uuid@habiter.app
  That's because the database is indexed on user email (because
  we are using pow library for authentication).
  """

  def create_guest_user() do
    <<short_id::binary-size(4)>> <> full_id = UUID.uuid4()

    {:ok, user} =
      %User{
        claimed: false,
        username: "Guest#{short_id}",
        email: "#{short_id <> full_id}@habiter.app",
        profile_picture_url: User.default_profile_picture()
      }
      |> Repo.insert()

    user
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset_without_pow(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Return a user struct populated with user data

  ## Examples

      iex> populate_user_struct(%{username: 'ads', ... })
      %User{username:'ads', ...}

  WARNING: if the data for input are wrong the function
  will just brake

  Using this cause at times we have maps (e.g. Presence map)
  and we need to make sure we can cast them back to user
  """
  def populate_user_struct(data) do
    User.populate(data)
  end
end
