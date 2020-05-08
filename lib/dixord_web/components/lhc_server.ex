defmodule DixordWeb.Components.LhcServer do
  use Surface.Component
  @doc "This is the server name"
  property(name, :string, required: true, default: "")
  property(active, :boolean, default: false)

  def render(assigns) do
    ~H"""
    <div class={{ "server-box", "bg-secondary": @active, "text-dark": @active }}>
      {{ @name }}
    </div>
    """
  end
end
