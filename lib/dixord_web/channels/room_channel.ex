defmodule DixordWeb.RoomChannel do
  use DixordWeb, :channel
  alias DixordWeb.Presence
  require Dixord.Messaging

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
  def handle_in(
        "shout",
        payload,
        socket = %{
          assigns: %{current_user: user, current_chat: chat}
        }
      ) do
    broadcast(socket, "shout", payload)

    if String.length(payload["message"]) > 0 do
      Dixord.Messaging.create_message(%{content: payload["message"]}, user, chat)
    end

    {:noreply, socket}
  end

  @docstring """
      Updates a dict payload on the metas object like metas.rotation or metas.position
  """
  def _update_presence_meta_dict(user, meta_key, payload_key, payload_value) do
    metas =
      DixordWeb.Presence.get_by_key(
        "room:lobby",
        user.id
      )[:metas]
      |> List.first()

    updated_meta_dict =
      Map.put(Map.get(metas, meta_key), String.to_atom(payload_key), payload_value)

    updated_metas = Map.put(metas, meta_key, updated_meta_dict)

    DixordWeb.Presence.update(
      self(),
      "room:lobby",
      user.id,
      updated_metas
    )
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
