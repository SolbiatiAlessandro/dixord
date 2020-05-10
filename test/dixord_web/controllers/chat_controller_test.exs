defmodule DixordWeb.ChatControllerTest do
  use DixordWeb.ConnCase

  alias Dixord.Messaging

  @create_attrs %{category: "some category", name: "some name", public: true}
  @update_attrs %{category: "some updated category", name: "some updated name", public: false}
  @invalid_attrs %{category: nil, name: nil, public: nil}

  def fixture(:chat) do
    {:ok, chat} = Messaging.create_chat(@create_attrs)
    chat
  end

  describe "index" do
    test "lists all chats", %{conn: conn} do
      conn = get(conn, Routes.chat_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Chats"
    end
  end

  describe "new chat" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.chat_path(conn, :new))
      assert html_response(conn, 200) =~ "New Chat"
    end
  end

  describe "show chat" do
    test "render messages of a chat", %{conn: conn} do
      user = Dixord.AccountsTest.user_fixture()
      chat = Dixord.MessagingTest.chat_fixture()

      {:ok, message1} =
        Messaging.create_message(
          %{content: "some content 1"},
          user,
          chat
        )

      {:ok, message2} =
        Messaging.create_message(
          %{content: "some content 2"},
          user,
          chat
        )

      conn = get(conn, Routes.chat_path(conn, :show, chat.id))
      assert html_response(conn, 200) =~ message1.content
      assert html_response(conn, 200) =~ message2.content
      assert html_response(conn, 200) =~ chat.description
    end
  end

  describe "create chat" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.chat_path(conn, :create), chat: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.chat_path(conn, :show, id)

      conn = get(conn, Routes.chat_path(conn, :show, id))
      assert html_response(conn, 200) =~ "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.chat_path(conn, :create), chat: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Chat"
    end
  end

  describe "edit chat" do
    setup [:create_chat]

    test "renders form for editing chosen chat", %{conn: conn, chat: chat} do
      conn = get(conn, Routes.chat_path(conn, :edit, chat))
      assert html_response(conn, 200) =~ "Edit Chat"
    end
  end

  describe "update chat" do
    setup [:create_chat]

    test "redirects when data is valid", %{conn: conn, chat: chat} do
      conn = put(conn, Routes.chat_path(conn, :update, chat), chat: @update_attrs)
      assert redirected_to(conn) == Routes.chat_path(conn, :show, chat)

      conn = get(conn, Routes.chat_path(conn, :show, chat))
      assert html_response(conn, 200) =~ "some updated category"
    end

    test "renders errors when data is invalid", %{conn: conn, chat: chat} do
      conn = put(conn, Routes.chat_path(conn, :update, chat), chat: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Chat"
    end
  end

  describe "delete chat" do
    setup [:create_chat]

    test "deletes chosen chat", %{conn: conn, chat: chat} do
      conn = delete(conn, Routes.chat_path(conn, :delete, chat))
      assert redirected_to(conn) == Routes.chat_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.chat_path(conn, :show, chat))
      end)
    end
  end

  defp create_chat(_) do
    chat = fixture(:chat)
    {:ok, chat: chat}
  end
end
