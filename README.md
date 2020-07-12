# Dixord
[![Build Status](https://travis-ci.com/SolbiatiAlessandro/dixord.svg)](https://travis-ci.com/SolbiatiAlessandro/dixord) [![codecov](https://codecov.io/gh/SolbiatiAlessandro/dixord/branch/master/graph/badge.svg)](https://codecov.io/gh/SolbiatiAlessandro/dixord)

![alt text](https://github.com/SolbiatiAlessandro/dixord/blob/master/dixord.png?raw=true)

Open source Discord clone build in Elixir, live at https://dixord.herokuapp.com
Read the blog post at http://www.lessand.ro/15/post.

## Docs

You can read the docs at https://dixord.herokuapp.com/index.html
Docs are generated with ex\_doc, and served statically from `priv/static`.

## LiveView/Sockets

We used to be server side rendered, but we found out that you can't do that while running tha game renderning loop.
Now we use Sockets, the workflow is a bit crappy but it works

- liveview uses pow to render the current user in the lhc
- javscript get the user id from there and use it to authenticate the socket
- the socket is use to broadcast and receive updates for the multiplayer game.

### Current problems 

1) people can hack it and impersonate other people sending a different `user_id` 
to the socket.connect method. For that we should look into Phoenix.Token
2) we are still using half LiveView half Socket, that's weird and we should move only to sockets and deprecate liveview

## Phoenix

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
