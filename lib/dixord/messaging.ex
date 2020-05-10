defmodule Dixord.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  import Ecto
  alias Dixord.Repo

  alias Dixord.Messaging.Message

  @doc """
  Returns the list of all messages.
  To retreive messages from a particular chat
  You can call `chat.messages`, after you have preloadeed them.
  refe. `get_chat!/1 returns messages for that chat` test for
  a code example.

  Messages are preloaded with user data cause
  we want user information attached for displaying
  username and profile picture together with the messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
    |> Repo.preload([:user])
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id) do
    Repo.get!(Message, id) |> Repo.preload([:user])
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    message =
      %Message{}
      |> Message.changeset(attrs)
      |> Repo.insert()
  end

  @doc """
  Creates a message with author association.

  ## Examples

      iex> user = create_user()
      iex> create_message(%{content: "test"}, user)
      {:ok, %Message{user_id = '123'}}

  """
  def create_message(attrs, user) do
    message = Ecto.build_assoc(user, :messages, attrs)
    Repo.insert(message)
  end

  @doc """
  Creates a message with author and chat association.

  ## Examples

      iex> user = create_user()
      iex> chat = create_chat()
      iex> create_message(%{content: "test"}, user, chat)
      {:ok, %Message{user_id = '123', chat_id = '123'}}

  """
  def create_message(message_attrs, user, chat) do
    message_changeset =
      user
      |> Ecto.build_assoc(:messages, message_attrs)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:chat, chat)

    Repo.insert(message_changeset)
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message()
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message() do
    change_message(%Message{})
  end

  alias Dixord.Messaging.Chat

  @doc """
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats do
    Repo.all(Chat)
  end

  @doc """
  List chats grouped by category, returns a [%{category_name: "..", chats: [%Chat{}]}]
  """
  def list_chats_grouped_by_category do
    chats = list_chats()

    categories =
      chats
      |> Enum.map(fn chat -> chat.category end)
      |> MapSet.new()

    chats_grouped_by_category =
      categories
      |> Enum.map(fn category ->
        %{
          category_name: category,
          chats: chats |> Enum.filter(fn chat -> chat.category == category end)
        }
      end)

    chats_grouped_by_category
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id) do
    Repo.get!(Chat, id)
    |> Repo.preload([:messages, {:messages, :user}])
  end

  @doc """
  get channel id to pass to
  endpoint.subscribe for LiveView
  for a given chat
  """
  def get_channel_id(chat) do
    Integer.to_string(chat.id)
  end

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{source: %Chat{}}

  """
  def change_chat(%Chat{} = chat) do
    Chat.changeset(chat, %{})
  end
end
