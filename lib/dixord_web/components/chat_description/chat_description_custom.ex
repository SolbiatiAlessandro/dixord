defmodule DixordWeb.Components.ChatDescription.Custom do
  @moduledoc """
  """
  use Surface.Component

  @doc "This is the chat description. If no description is provided
  it renders default Dixord intro"
  property(description, :string, default: "")

  def render(assigns) do
    ~H"""
    <div class="row">
      <div class="col-2">
        <img src="">
      </div>
      <div class="col-10">
        <p>{{ @description }}</p>
      </div>
    </div>
    """
  end
end
