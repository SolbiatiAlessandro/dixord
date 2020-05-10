defmodule DixordWeb.PageControllerTest do
  use DixordWeb.ConnCase

  test "GET /", %{conn: conn} do
    # the home page redirects us to the welcome chat
    conn = get(conn, "/")
    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == Routes.chat_path(conn, :show, id)
  end
end
