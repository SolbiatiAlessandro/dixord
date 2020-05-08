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
  require Pow.Plug
  plug(:authenticate_user)

  def index(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      Dixord.ChatLiveView,
      session: %{"current_user" => conn.assigns.current_user}
    )
  end

  def authenticate_user(conn, _params) do
    current_user =
      if Pow.Plug.current_user(conn),
        do:
          Pow.Plug.current_user(conn).id
          |> Dixord.Accounts.get_user!(),
        else: Dixord.Accounts.create_guest_user()

    assign(
      conn,
      :current_user,
      current_user
    )
  end
end
