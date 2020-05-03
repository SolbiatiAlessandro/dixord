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

	def render(assigns) do
	  DixordWeb.PageView.render("index.html", assigns)
	end

	def handle_event("message", %{"message" => message_params}, socket) do
	  Logger.info("handle_event message")
	  Chats.create_message(message_params)
	  messages = Dixord.Message.get_messages()
	  {:noreply, assign(socket, :messages, messages)}
	end

	@impl true
    def mount(_params, _session, socket) do
	  messages = Dixord.Message.get_messages()
	  {:ok, assign(
			  socket, 
			  messages: messages, 
			  message: Dixord.Message.change_message()
			)}
    end
end
