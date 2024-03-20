defmodule Angen.Account.DefaultsPlug do
  @moduledoc false
  # import Plug.Conn

  @spec init(list()) :: list()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
  end
end
