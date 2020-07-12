defmodule DixordWeb.RoomChannel do
  use DixordWeb, :channel
  alias DixordWeb.Presence

  def join("room:lobby", payload, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_info(:after_join, socket) do
    user = socket.assigns.current_user

    Presence.track(socket, user.id, %{
      user_id: user.id,
      username: user.username,
      profile_picture_url: user.profile_picture_url
    })

    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
