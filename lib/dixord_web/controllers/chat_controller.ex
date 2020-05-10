defmodule DixordWeb.ChatController do
  use DixordWeb, :controller

  alias Dixord.Messaging
  alias Dixord.Messaging.Chat

  def index(conn, _params) do
    chats = Messaging.list_chats()
    render(conn, "index.html", chats: chats)
  end

  def new(conn, _params) do
    changeset = Messaging.change_chat(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  def new(conn, %{"category_name" => category_name}) do
    changeset = Messaging.change_chat(%Chat{})
    render(conn, "new.html", changeset: changeset, category_name: category_name)
  end

  def create(conn, %{"chat" => chat_params}) do
    case Messaging.create_chat(chat_params) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat created successfully.")
        |> redirect(to: Routes.chat_path(conn, :show, chat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    chat = Messaging.get_chat!(id)

    Phoenix.LiveView.Controller.live_render(
      conn,
      Dixord.ChatLiveView,
      session: %{
        "current_user" => conn.assigns.current_user,
        "current_chat" => chat
      }
    )
  end

  def edit(conn, %{"id" => id}) do
    chat = Messaging.get_chat!(id)
    changeset = Messaging.change_chat(chat)
    render(conn, "edit.html", chat: chat, changeset: changeset)
  end

  def update(conn, %{"id" => id, "chat" => chat_params}) do
    chat = Messaging.get_chat!(id)

    case Messaging.update_chat(chat, chat_params) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat updated successfully.")
        |> redirect(to: Routes.chat_path(conn, :show, chat))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", chat: chat, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    chat = Messaging.get_chat!(id)
    {:ok, _chat} = Messaging.delete_chat(chat)

    conn
    |> put_flash(:info, "Chat deleted successfully.")
    |> redirect(to: Routes.chat_path(conn, :index))
  end
end
