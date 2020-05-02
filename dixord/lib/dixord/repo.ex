defmodule Dixord.Repo do
  use Ecto.Repo,
    otp_app: :dixord,
    adapter: Ecto.Adapters.Postgres
end
