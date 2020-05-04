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

  def handle_event("message", %{"message" => message_params}, socket) do
    Dixord.Message.create_message(message_params)
    messages = Dixord.Message.get_messages()
    Logger.info("before broadcast")
    DixordWeb.Endpoint.broadcast_from(self(), "lobby", "message", %{messages: messages})
    {:noreply, assign(socket, :messages, messages)}
  end

  @impl true
  def mount(_params, %{"current_user" => current_user}, socket) do
    DixordWeb.Endpoint.subscribe("lobby")
    messages = Dixord.Message.get_messages()
    {:ok, assign(
      socket, 
      messages: messages, 
      message: Dixord.Message.change_message(),
      current_user: current_user
    )}
  end
end
