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
  alias Dixord.Messaging

  def index(conn, _params) do
    chat = Messaging.get_chat!(1)

    Phoenix.LiveView.Controller.live_render(
      conn,
      Dixord.GameLiveView,
      session: %{
        "current_user" => conn.assigns.current_user,
        "current_chat" => chat
      }
    )
  end
end
