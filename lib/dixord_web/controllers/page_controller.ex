defmodule DixordWeb.PageController do
  @moduledoc """
  An introduction on views and template is here
  https://hexdocs.pm/phoenix/views.html#content

  The templates are rendered like layout -> page
  I didn't figure out where layout/app is called in the code.

  An explaination of partial templates is in 
  https://elixircasts.io/partial-templates-with-phoenix
  """
  use DixordWeb, :controller
  plug :authenticate_guest_user
  @guests_profile_images %{
    red: "https://discordapp.com/assets/1cbd08c76f8af6dddce02c5138971129.png",
    blue: "https://discordapp.com/assets/6debd47ed13483642cf09e832ed0bc1b.png",
    yellow: "https://discordapp.com/assets/0e291f67c9274a1abdddeb3fd919cbaa.png",
    green: "https://discordapp.com/assets/dd4dbc0016779df1378e7812eabaa04d.png",
    grey: "https://discordapp.com/assets/322c936a8c8be1b803cd94861bdfa868.png"
  }

  def index(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      Dixord.ChatLiveView,
      session: %{"current_user" => conn.assigns.current_user}
    )
  end

  def authenticate_guest_user(conn, _params) do
    random_id = :rand.uniform(1000)
    assign(
      conn, 
      :current_user, 
      %{
        id: "#{random_id}",
        username: "Guest#{random_id}",
        profile_picture_url: @guests_profile_images 
        |> Map.values() 
        |> Enum.random()
      }
    )
  end
end
