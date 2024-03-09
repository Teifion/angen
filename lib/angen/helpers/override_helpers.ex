defmodule Angen.Helpers.OverrideHelpers do
  @moduledoc """
  Overrides for Teiserver functions
  """

  @spec lobby_name_acceptor(String.t()) :: boolean
  def lobby_name_acceptor(_name) do
    true
  end

  @spec user_name_acceptor(String.t()) :: boolean
  def user_name_acceptor(_name) do
    true
  end
end
