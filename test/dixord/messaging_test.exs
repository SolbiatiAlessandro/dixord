defmodule Dixord.MessagingTest do
  use Dixord.DataCase

  alias Dixord.Messaging

  describe "messages" do
    alias Dixord.Messaging.Message

    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}
    @invalid_attrs %{content: nil}

    def message_fixture(attrs \\ %{}) do
      user = Dixord.AccountsTest.user_fixture()
      chat = chat_fixture()

      {:ok, message} =
        Messaging.create_message(
          @valid_attrs,
          user,
          chat
        )

      message
    end

    test "list_messages/0 returns all messages" do
      user = Dixord.AccountsTest.user_fixture()

      {:ok, message} =
        Messaging.create_message(
          @valid_attrs,
          user
        )

      messages = Messaging.list_messages()
      assert Enum.member?(messages, Messaging.get_message!(message.id))
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messaging.get_message!(message.id).id == message.id
    end

    test "create_message/2 with valid data creates a message" do
      user = Dixord.AccountsTest.user_fixture()

      assert {:ok, message} =
               Messaging.create_message(
                 @valid_attrs,
                 user
               )

      assert message.content == "some content"
      assert message.user_id == user.id
    end

    test "create_message/3 with valid data creates a message" do
      user = Dixord.AccountsTest.user_fixture()
      chat = chat_fixture()

      assert {:ok, message} =
               Messaging.create_message(
                 @valid_attrs,
                 user,
                 chat
               )

      assert message.content == "some content"
      assert message.user_id == user.id
      assert message.chat_id == chat.id
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Messaging.create_message(@valid_attrs)
      assert message.content == "some content"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Messaging.update_message(message, @update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_message(message, @invalid_attrs)
      assert message.id == Messaging.get_message!(message.id).id
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messaging.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messaging.change_message(message)
    end
  end

  describe "chats" do
    alias Dixord.Messaging.Chat

    @valid_attrs %{
      category: "some category",
      name: "some name",
      public: true,
      description: "some description"
    }
    @update_attrs %{category: "some updated category", name: "some updated name", public: false}
    @invalid_attrs %{category: nil, name: nil, public: nil}

    def chat_fixture(attrs \\ %{}) do
      {:ok, chat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messaging.create_chat()

      chat
    end

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Enum.member?(Messaging.list_chats(), chat)
    end

    test "list_chats_grouped_by_category/0 returns all chats" do
      chat1 = chat_fixture()
      chat2 = chat_fixture()
      chat3 = chat_fixture(%{category: "some other category"})
      chats = Messaging.list_chats_grouped_by_category()
      # (we could put the following functions into an API)
      # does category exists?
      assert Enum.member?(Enum.map(chats, fn x -> x.category_name end), "some category")
      assert Enum.member?(Enum.map(chats, fn x -> x.category_name end), "some other category")
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Messaging.get_chat!(chat.id).id == chat.id
      assert Messaging.get_chat!(chat.id).description == chat.description
    end

    test "get_chat!/1 returns messages for that chat" do
      chat = chat_fixture()
      user = Dixord.AccountsTest.user_fixture()

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

      message1_preloaded = Messaging.get_message!(message1.id)
      message2_preloaded = Messaging.get_message!(message2.id)

      assert Messaging.get_chat!(chat.id).id == chat.id
      [message1_test, message2_test] = Messaging.get_chat!(chat.id).messages
      assert message1_test.id == message1_preloaded.id
      assert message1_test.user.id == message1_preloaded.user.id
      assert message2_test.id == message2_preloaded.id
      assert message2_test.user.id == message2_preloaded.user.id
    end

    test "create_chat/1 with valid data creates a chat" do
      assert {:ok, %Chat{} = chat} = Messaging.create_chat(@valid_attrs)
      assert chat.category == "some category"
      assert chat.name == "some name"
      assert chat.public == true
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{} = chat} = Messaging.update_chat(chat, @update_attrs)
      assert chat.category == "some updated category"
      assert chat.name == "some updated name"
      assert chat.public == false
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_chat(chat, @invalid_attrs)
      assert chat.id == Messaging.get_chat!(chat.id).id
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Messaging.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Messaging.change_chat(chat)
    end
  end
end
