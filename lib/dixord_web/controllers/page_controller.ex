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

  def index(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      Dixord.ChatLiveView,
      session: %{"current_user" => conn.assigns.current_user}
    )
  end

  def authenticate_guest_user(conn, _params) do
    {:ok, guest_user} = Dixord.Accounts.create_guest_user()
    random_id = :rand.uniform(1000)
    assign(
      conn, 
      :current_user, 
      guest_user
    )
  end
end
