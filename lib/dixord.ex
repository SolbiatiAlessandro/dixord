defmodule Dixord do
  @moduledoc """
  These are the Dixord docs. We suggest starting from [Dixord Introduction](https://dixord.herokuapp.com/Dixord.html).

  Dixord is an open source discord clone built in Elixir.
  Is great if you want to learn how to build a chat app in Elixir.

  This docs are generated through `ex_doc` and served statically at `priv/static`

  # Elixir/Phoenix resources

  These are some resources helpful to navigate Dixord code from the 
  official documentation.

  - Directory Strucutre: https://hexdocs.pm/phoenix/directory_structure.html
  - Requests Cycle: https://hexdocs.pm/phoenix/request_lifecycle.html#content

  These are some other open source Elixir repo to have a look at the code
  to see the best practices

  - https://github.com/phoenixframework/phoenix
  - https://github.com/thechangelog/changelog.com

  # Dev Workflow

  Edit code
  `mix compile`
  `mix phx.server`, this might have connections already present and throw
  and `address already in use`. You can use `kill -9 (lsof -ti :4000)`
  to kill all existing processes
  git add *
  git commit 
  git push heroku master

  # Dixord Architecture

  Dixord is built in Phoenix in the backend, and for now
  in the front-end we just use Elixir templates and Bootstrap.
  We didn't go for more complex solutions (React) because the project 
  is still early.
  """
end
