defmodule Teiserver.Caches.UserLoginCache do
  @moduledoc """
  Cache for anything related to user logins built in addition to Teiserver functionality
  """

  use Supervisor
  import Teiserver.Helpers.CacheHelper, only: [add_cache: 2]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:one_time_login_code, ttl: :timer.seconds(30)),
      add_cache(:user_token_identifier_cache, ttl: :timer.minutes(5))
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
