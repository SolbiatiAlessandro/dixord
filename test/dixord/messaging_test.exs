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
      {:ok, message} = Messaging.create_message(
        @valid_attrs,
        user
      )
      message
    end

    test "list_messages/0 returns all messages" do
      user = Dixord.AccountsTest.user_fixture()
      {:ok, message} = Messaging.create_message(
        @valid_attrs,
        user
      )
      messages = Messaging.list_messages()
      Enum.each(messages, fn m -> assert m.id == message.id end)
      Enum.each(messages, fn m -> assert m.user_id == user.id end)
      Enum.each(messages, fn m -> assert m.user.username == user.username end)
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messaging.get_message!(message.id) == message
    end

    test "create_message/2 with valid data creates a message" do
      user = Dixord.AccountsTest.user_fixture()
      assert {:ok, message} = Messaging.create_message(
        @valid_attrs,
        user
      )
      assert message.content == "some content"
      assert message.user_id == user.id
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
      assert message == Messaging.get_message!(message.id)
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
end
