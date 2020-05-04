defmodule Dixord.ChatLiveView do
  @moduledoc"""
  This is server side rendered code, you can think of this
  like a react component but server side. It has a mount method
  and a render method, just like react. 

  In the template you call this with something like
      <%= live_render(@conn, Dixord.ChatLiveView) %>
  You could also render stuff from the controller/router if you wanted.
  """
  use Phoenix.LiveView
  import Logger

  def render(assigns) do
    DixordWeb.PageView.render("index.html", assigns)
  end

  def handle_info(%{event: "message", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users = DixordWeb.Presence.list("lobby") 
            |> Enum.map(fn {_current_user, data} ->
              data[:metas]
              |> List.first()
            end)
    {:noreply, assign(socket, users: users)}
  end

  def handle_event("message", %{"message" => message_params}, socket) do
    Dixord.Message.create_message(message_params)
    messages = Dixord.Message.get_messages()
    DixordWeb.Endpoint.broadcast_from(self(), "lobby", "message", %{messages: messages})
    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_event("typing", _value, socket = %{assigns: %{current_user: user}}) do
    payload = %{typing: true}
    metas = DixordWeb.Presence.get_by_key("lobby", user.id)[:metas]
            |> List.first()
            |> Map.merge(payload)

    DixordWeb.Presence.update(self(), "lobby", user.id, metas)
    {:noreply, socket}
  end

  def handle_event("stop_typing", _value, socket = %{assigns: %{current_user: user}}) do
    payload = %{typing: false}
    metas = DixordWeb.Presence.get_by_key("lobby", user.id)[:metas]
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
    messages = Dixord.Message.get_messages()
    users = DixordWeb.Presence.list("lobby") 
            |> Enum.map(fn {_current_user, data} ->
              data[:metas]
              |> List.first()
            end)
    {:ok, assign(
      socket, 
      messages: messages, 
      message: Dixord.Message.change_message(),
      current_user: current_user,
      users: users
    )}
  end
end
