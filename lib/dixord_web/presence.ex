defmodule DixordWeb.Presence do
  use Phoenix.Presence,
    otp_app: :dixord,
    pubsub_server: Dixord.PubSub
end
