defmodule DixordWeb.Presence do
  use Phoenix.Presence,
    otp_app: :dixord,
    pubsub_server: Dixord.PubSub

  def track_user_join(socket, user) do
    Presence.track(socket, user.id, %{
      user_id: user.id
    })
  end
end
