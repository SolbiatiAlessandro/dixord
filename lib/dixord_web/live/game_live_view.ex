defmodule Dixord.GameLiveView do
  @moduledoc """
  This is server side rendered code, you can think of this
  like a react component but server side. It has a mount method
  and a render method, just like react. 

  In the template you call this with something like
      <%= live_render(@conn, Dixord.ChatLiveView) %>
  You could also render stuff from the controller/router if you wanted.
  """
  use Phoenix.LiveView
  require Dixord.Messaging
  require DixordWeb.ChatView
  alias DixordWeb.Endpoint
  require DixordWeb.Components.LhcChat

  @spec _process_presence(%Dixord.Messaging.Chat{}) :: {
          list(%Dixord.Accounts.User{}),
          list(map())
        }
  @doc """
  Utility to process DixordWeb.Presence updates
  for users connected to the LiveView

  returns `{users, users_presence}` where

  users_presence:
    presence data, :metas is a map with fields
    like phx_ref, username, and typing. 
  :metas is defined at Presence.track

  users:
    users data (this is a %User{} struct)
    that can be used when we need the guarantee 
    this is a real User

  """
  def _process_presence(current_chat) do
    users_presence =
      current_chat
      |> Dixord.Messaging.get_channel_id()
      |> DixordWeb.Presence.list()
      |> Enum.map(fn {_current_user, data} ->
        data[:metas]
        |> List.first()
      end)

    users =
      Enum.map(
        users_presence,
        fn user_data ->
          Dixord.Accounts.populate_user_struct(user_data)
        end
      )

    {users, users_presence}
  end

  def render(assigns) do
    DixordWeb.GameView.render("index.html", assigns)
  end

  def handle_info(%{event: "message", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {users, users_presence} =
      socket.assigns.current_chat
      |> _process_presence()

    {:noreply,
     assign(
       socket,
       users: users,
       users_presence: users_presence
     )}
  end

  def handle_event(
        "player-position-updated",
        %{"axis" => axis, "value" => value},
        socket = %{
          assigns: %{current_user: user, current_chat: chat}
        }
      ) do
    payload = Map.put_new(%{}, String.to_atom(axis), value)

    metas =
      DixordWeb.Presence.get_by_key(
        Dixord.Messaging.get_channel_id(chat),
        user.id
      )[:metas]
      |> List.first()
      |> Map.merge(payload)

    DixordWeb.Presence.update(
      self(),
      Dixord.Messaging.get_channel_id(chat),
      user.id,
      metas
    )

    {:noreply, socket}
  end

  @doc """
  Callback function that gets triggered when a user sends a message
  """
  def handle_event(
        "message",
        %{"message" => message_params},
        socket = %{
          assigns: %{current_user: user, current_chat: chat}
        }
      ) do
    # for some reason message_params has strings as key and I need atoms
    # https://stackoverflow.com/questions/31990134
    atom_message_params =
      for {key, val} <- message_params, into: %{}, do: {String.to_atom(key), val}

    # can't send empty messages
    if String.length(atom_message_params.content) > 0 do
      Dixord.Messaging.create_message(atom_message_params, user, chat)
    end

    # reload chat to get the updates messages
    chat = Dixord.Messaging.get_chat!(chat.id)
    messages = chat.messages

    DixordWeb.Endpoint.broadcast_from(
      self(),
      Dixord.Messaging.get_channel_id(chat),
      "message",
      %{messages: messages, current_chat: chat}
    )

    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_event(
        "typing",
        _value,
        socket = %{
          assigns: %{current_user: user, current_chat: chat}
        }
      ) do
    payload = %{typing: true}

    metas =
      DixordWeb.Presence.get_by_key(
        Dixord.Messaging.get_channel_id(chat),
        user.id
      )[:metas]
      |> List.first()
      |> Map.merge(payload)

    DixordWeb.Presence.update(
      self(),
      Dixord.Messaging.get_channel_id(chat),
      user.id,
      metas
    )

    {:noreply, socket}
  end

  def handle_event(
        "stop_typing",
        _value,
        socket = %{
          assigns: %{current_user: user, current_chat: chat}
        }
      ) do
    payload = %{typing: false}

    metas =
      DixordWeb.Presence.get_by_key(
        Dixord.Messaging.get_channel_id(chat),
        user.id
      )[:metas]
      |> List.first()
      |> Map.merge(payload)

    DixordWeb.Presence.update(
      self(),
      Dixord.Messaging.get_channel_id(chat),
      user.id,
      metas
    )

    {:noreply, socket}
  end

  @doc """
  This is the mount for the chat LiveView, it does a bunch
  of thing to set up the chat, most importantly loads messages,
  chats, and set current_user and current_chat for the .eex
  """
  def mount(
        _params,
        %{
          "current_user" => current_user,
          "current_chat" => current_chat
        },
        socket
      ) do
    current_chat
    |> Dixord.Messaging.get_channel_id()
    |> DixordWeb.Endpoint.subscribe()

    DixordWeb.Presence.track(
      self(),
      Dixord.Messaging.get_channel_id(current_chat),
      current_user.id,
      %{
        id: current_user.id,
        username: current_user.username,
        profile_picture_url: current_user.profile_picture_url,
        typing: false,
        x: 0,
        y: 0,
        z: 0
      }
    )

    messages = current_chat.messages

    {users, users_presence} =
      current_chat
      |> _process_presence()

    chats = Dixord.Messaging.list_chats_grouped_by_category()

    {:ok,
     assign(
       socket,
       chats: chats,
       messages: messages,
       message: Dixord.Messaging.change_message(),
       current_user: current_user,
       current_chat: current_chat,
       users: users,
       users_presence: users_presence,
       conn: Endpoint
     )}
  end
end
