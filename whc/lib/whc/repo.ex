defmodule Whc.Repo do
  use Ecto.Repo,
    otp_app: :whc,
    adapter: Ecto.Adapters.Postgres
end
