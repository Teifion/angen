defmodule Angen.Helpers.NumberHelper do
  @moduledoc """
  Functions to assist with numerical operations
  """

  @doc """
  Identical to `round/1` except it will round to a specific number of decimal places

    round(456.777, 2)
    > 456.78
  """
  @spec round(number(), non_neg_integer()) :: integer() | float()
  def round(value, decimal_places) do
    dp_mult = :math.pow(10, decimal_places)
    round(value * dp_mult) / dp_mult
  end
end
