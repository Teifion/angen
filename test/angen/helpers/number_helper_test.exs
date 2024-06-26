defmodule Angen.General.NumberHelperTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Helpers.NumberHelper
  alias Decimal

  test "round" do
    params = [
      {123, 123},
      {987.4, 987.4},
      {456.777, 456.78},
      {456.774, 456.77},
      {456.123456, 456.12},
      {456.056, 456.06}
    ]

    for {input, expected} <- params do
      result = NumberHelper.round(input, 2)
      assert result == expected
    end
  end
end
