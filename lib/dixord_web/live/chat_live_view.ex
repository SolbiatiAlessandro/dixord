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
	  <p class="text-secondary">The following is all <b>server side rendered</b>...</p>
	  <%= for message <- @messages do %>
		<li class="mt-2 d-flex align-items-start livechat-row">
		  <div class="mr-3">
			<img src="https://discordapp.com/assets/6debd47ed13483642cf09e832ed0bc1b.png">
		  </div>
		  <div>
			<div class="d-flex aligns-items-end">
			  <h5 class="mr-3 mb-1"><%= message.name %></h5>
			  <p class="font-weight-light text-secondary mb-1"><%= message.inserted_at %></p>
			</div>
			<div class="body">
			  <p><%= message.message %></p>
			</div>
		  </div>
		</li>
	  <% end %>
	  """
	end

	@impl true
    def mount(_params, _session, socket) do
	  messages = Dixord.Message.get_messages()
	  {:ok, assign(socket, :messages, messages)}
    end
end
