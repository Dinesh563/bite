defmodule Bite.Repo do
  use Ecto.Repo,
    otp_app: :bite,
    adapter: Ecto.Adapters.Postgres
end
