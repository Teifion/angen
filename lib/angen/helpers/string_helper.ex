defmodule Angen.Helper.StringHelper do
  def format_number(nil), do: nil
  def format_number(%Decimal{} = v), do: v |> Decimal.to_string() |> format_number
  def format_number(v) when v < 1000, do: v

  def format_number(v) when is_integer(v) do
    v
    |> Integer.to_string()
    |> format_number
  end

  def format_number(v) when is_float(v) do
    v
    |> Float.to_string()
    |> format_number
  end

  def format_number(v) do
    v
    |> String.replace(~r/[0-9](?=(?:[0-9]{3})+(?![0-9]))/, "\\0,")
  end
end
