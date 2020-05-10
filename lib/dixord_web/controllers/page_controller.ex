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

  def get_landing_chat_path(conn) do
    landing_chat_id = 1
    Routes.chat_path(conn, :show, landing_chat_id)
  end

  def index(conn, _params) do
    conn |> redirect(to: get_landing_chat_path(conn))
  end
end
