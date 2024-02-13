defmodule Angen.Repo do
  use Ecto.Repo,
    otp_app: :angen,
    adapter: Ecto.Adapters.Postgres
end
