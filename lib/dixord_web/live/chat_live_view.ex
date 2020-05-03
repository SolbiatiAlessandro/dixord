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
	  ~L"""
	  <p>The following is all <b>server side rendered</b></p>
	  <%= for message <- @messages do %>
		<li><b><%= message.name %></b>, <%= message.message %></li>
	  <% end %>
	  """
	end

	@impl true
    def mount(_params, _session, socket) do
	  messages = Dixord.Message.get_messages()
	  {:ok, assign(socket, :messages, messages)}
    end
end
