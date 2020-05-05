defmodule DixordWeb.ChatLiveViewTest do
  @moduledoc"""
  Testing the live view to check the before after migration
  of messages infra every works.

  Example are
  - https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#content
  - https://github.com/flash4syth/provo_live/blob/8139bc608f27d8b922f1bdf89edf4d0edbfc9a09/test/provo_live_web/live/my_live_view_test.exs
  """
  use DixordWeb.ConnCase
  require Phoenix.LiveViewTest

  test "mount", %{conn: conn} do
    {:ok, view, html} = Phoenix.LiveViewTest.live(conn, "/")
    # assert that there is the string Message
    # from the composer e.g. "Message this chat.."
    assert html =~ "Message"
    assert html =~ "Dixord"
  end
end
