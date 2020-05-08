defmodule Dixord.ChatLiveView do
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
  alias DixordWeb.Endpoint
  require DixordWeb.Components.LhcChat

  @spec _process_presence() :: {
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

  users:
    users data (this is a %User{} struct)
    that can be used when we need the guarantee 
    this is a real User

  """
  def _process_presence() do
    users_presence =
      DixordWeb.Presence.list("lobby")
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
    DixordWeb.PageView.render("index.html", assigns)
  end

  def handle_info(%{event: "message", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {users, users_presence} = Dixord.ChatLiveView._process_presence()

    {:noreply,
     assign(
       socket,
       users: users,
       users_presence: users_presence
     )}
  end

  @doc """
  Callback function that gets triggered when a user sends a message
  """
  def handle_event("message", %{"message" => message_params}, socket) do
    # for some reason message_params has strings as key and I need atoms
    # https://stackoverflow.com/questions/31990134
    atom_message_params =
      for {key, val} <- message_params, into: %{}, do: {String.to_atom(key), val}

    # can't send empty messages
    if String.length(atom_message_params.content) > 0 do
      Dixord.Messaging.create_message(atom_message_params, socket.assigns.current_user)
    end

    messages = Dixord.Messaging.list_messages()
    DixordWeb.Endpoint.broadcast_from(self(), "lobby", "message", %{messages: messages})
    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_event("typing", _value, socket = %{assigns: %{current_user: user}}) do
    payload = %{typing: true}

    metas =
      DixordWeb.Presence.get_by_key("lobby", user.id)[:metas]
      |> List.first()
      |> Map.merge(payload)

    DixordWeb.Presence.update(self(), "lobby", user.id, metas)
    {:noreply, socket}
  end

  def handle_event("stop_typing", _value, socket = %{assigns: %{current_user: user}}) do
    payload = %{typing: false}

    metas =
      DixordWeb.Presence.get_by_key("lobby", user.id)[:metas]
      |> List.first()
      |> Map.merge(payload)

    DixordWeb.Presence.update(self(), "lobby", user.id, metas)
    {:noreply, socket}
  end

  @impl true
  def mount(_params, %{"current_user" => current_user}, socket) do
    DixordWeb.Endpoint.subscribe("lobby")

    DixordWeb.Presence.track(
      self(),
      "lobby",
      current_user.id,
      %{
        id: current_user.id,
        username: current_user.username,
        profile_picture_url: current_user.profile_picture_url,
        typing: false
      }
    )

    messages = Dixord.Messaging.list_messages()
    {users, users_presence} = Dixord.ChatLiveView._process_presence()

    {:ok,
     assign(
       socket,
       messages: messages,
       message: Dixord.Messaging.change_message(),
       current_user: current_user,
       users: users,
       users_presence: users_presence,
       conn: Endpoint
     )}
  end
end
