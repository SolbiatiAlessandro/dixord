defmodule DixordWeb.Components.ChatDescription.Row do
  @moduledoc """
  Basic row for chat description
  """
  use Surface.Component

  @doc """
  Choose which icon you want to be rendered
  """
  property(icon, :string)
  property(descripton, :string, default: "")

  property(icons, :map,
    default: %{
      "bang" => "https://discord.com/assets/7616be62f9b90270b5a2e1fe9d2ece4f.svg",
      "computer" => "https://discord.com/assets/db7900a7a191ecf1949f15dd20dce2b2.svg",
      "pen" => "https://discord.com/assets/f0d5ce11fa72f4a97747256faa345e7b.svg"
    }
  )

  def render(assigns) do
    ~H"""
    <div class="row">
      <div class="col-2 pr-0 text-right">
        <img style="height:60px" src="{{ @icons[@icon] }}">
      </div>
      <div class="col-10">
        <p>{{ @description }}</p>
      </div>
    </div>
    """
  end
end
