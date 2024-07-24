defmodule Angen.Account.SecureApiPlug do
  @moduledoc false
  # import Plug.Conn

  @spec init(list()) :: list()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, opts) do
    IO.puts "#{__MODULE__}:#{__ENV__.line}"
    IO.inspect conn
    IO.puts ""

    IO.puts "#{__MODULE__}:#{__ENV__.line}"
    IO.inspect opts
    IO.puts ""

    conn
  end
end
