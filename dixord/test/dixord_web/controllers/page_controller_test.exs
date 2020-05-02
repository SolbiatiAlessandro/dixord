defmodule DixordWeb.PageControllerTest do
  use DixordWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "dixord"
  end
end
