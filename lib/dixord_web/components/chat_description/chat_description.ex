defmodule DixordWeb.Components.ChatDescription do
  @moduledoc """
  This is "megaphone" component that format description of a chat to
  be rendered on top of the message.
  """
  use Surface.Component

  @doc "This is the chat name"
  property(name, :string, required: true, default: "")
  @doc "This is the chat description. If no description is provided
  it renders default Dixord intro"
  property(description, :string, default: "")

  def render(assigns) do
    ~H"""
    <div class="row" style="margin-top:20%;margin-bottom:10%;">
      <div class="col-md-3"></div>
      <div class="col-md-6 col-sm-auto">
        <h1 class="text-center mb-3">#{{ @name }}</h1>
        <DixordWeb.Components.ChatDescription.Default :if={{ @description == "" }} />
        <DixordWeb.Components.ChatDescription.Row icon="bang" description="{{ @description }}" :if={{ @description != "" }} />
      </div>
      <div class="col-md-3"></div>
    </div>
    """
  end
end
