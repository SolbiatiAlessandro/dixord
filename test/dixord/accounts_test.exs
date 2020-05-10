defmodule Dixord.AccountsTest do
  use Dixord.DataCase
  require Dixord.Accounts
  alias Dixord.Accounts

  describe "users" do
    alias Dixord.Accounts.User

    @valid_attrs %{
      claimed: true,
      profile_picture_url: "some profile_picture_url",
      username: "some username",
      email: "test1234@example.com",
      password: "12345678",
      password_confirmation: "12345678"
    }
    @update_attrs %{
      claimed: false,
      profile_picture_url: "some updated profile_picture_url",
      username: "some updated username",
      email: "updatedemail@email.com",
      current_password: "12345678",
      updated_password: "updatedpassword2"
    }
    @invalid_attrs %{
      claimed: nil,
      profile_picture_url: nil,
      username: nil,
      email: nil,
      password: nil,
      password_confirmation: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      users = Accounts.list_users()
      assert Enum.member?(users, Accounts.get_user!(user.id))
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id).id == user.id
      assert Accounts.get_user!(user.id).username == user.username
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.claimed == true
      assert user.profile_picture_url == "some profile_picture_url"
      assert user.username == "some username"
    end

    test "create_guest_user/0 creates a guest user" do
      user = Accounts.create_guest_user()
      assert user
      assert user.claimed == false

      assert Enum.member?(
               Application.fetch_env!(:dixord, :guests_profile_images)
               |> Map.values(),
               user.profile_picture_url
             )

      assert user.username =~ "Guest"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.claimed == false
      assert user.profile_picture_url == "some updated profile_picture_url"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user.id == Accounts.get_user!(user.id).id
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
