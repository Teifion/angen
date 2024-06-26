defmodule Angen.General.StringHelpersTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Helper.StringHelper

  test "format_number" do
    params = [
      {nil, nil},
      {Decimal.new(100), "100"},
      {100, 100},
      {100.50, 100.5},
      {10_000.50, "10,000.5"},
      {100_000, "100,000"},
      {100_000_000_000_000, "100,000,000,000,000"}
    ]

    for {input, expected} <- params do
      result = StringHelper.format_number(input)
      assert result == expected
    end
  end
end
