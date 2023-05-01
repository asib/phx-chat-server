defmodule LiveElist.Repo do
  use Ecto.Repo,
    otp_app: :live_elist,
    adapter: Ecto.Adapters.Postgres
end
