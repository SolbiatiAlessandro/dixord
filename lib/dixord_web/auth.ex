defmodule DixordWeb.Auth do
  @moduledoc """
  Authentication is either with a unclaimed guest user, or with a 
  standard logged in user.

  This module provide the authenticaton logic (built on top of plug)
  that we pipe_through in the browser as a plug in all the modules
  we need.
  """
  use DixordWeb, :controller
  require Pow.Plug

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
