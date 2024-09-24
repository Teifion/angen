defmodule Angen.Helpers.DatetimehelperTest do
  @moduledoc false
  use Angen.DataCase, async: true
  alias Angen.Helper.DateTimeHelper

  describe "beginning and end of" do
    test "beginning_of_day" do
      [
        {~U[2024-02-01 01:02:03Z], ~U[2024-02-01 00:00:00.0Z]},
        {~U[2024-02-01 23:02:03Z], ~U[2024-02-01 00:00:00.0Z]}
      ]
      |> Enum.each(fn {value, expected_result} ->
        result = DateTimeHelper.beginning_of_day(value)

        assert result == expected_result,
          message:
            "DateTimeHelper.beginning_of_day(#{inspect(value)}) = #{inspect(result)} but expected #{inspect(expected_result)}"
      end)
    end

    test "beginning_of_quarter" do
      [
        {~D[2024-01-01], ~D[2024-01-01]},
        {~D[2024-01-02], ~D[2024-01-01]},
        {~D[2024-02-01], ~D[2024-01-01]},
        {~D[2024-02-02], ~D[2024-01-01]},
        {~D[2024-03-01], ~D[2024-01-01]},
        {~D[2024-03-02], ~D[2024-01-01]},
        {~D[2024-04-01], ~D[2024-04-01]},
        {~D[2024-04-02], ~D[2024-04-01]},
        {~D[2024-05-01], ~D[2024-04-01]},
        {~D[2024-05-02], ~D[2024-04-01]},
        {~D[2024-06-01], ~D[2024-04-01]},
        {~D[2024-06-02], ~D[2024-04-01]},
        {~D[2024-07-01], ~D[2024-07-01]},
        {~D[2024-07-02], ~D[2024-07-01]},
        {~D[2024-08-01], ~D[2024-07-01]},
        {~D[2024-08-02], ~D[2024-07-01]},
        {~D[2024-09-01], ~D[2024-07-01]},
        {~D[2024-09-02], ~D[2024-07-01]},
        {~D[2024-10-01], ~D[2024-10-01]},
        {~D[2024-10-02], ~D[2024-10-01]},
        {~D[2024-11-01], ~D[2024-10-01]},
        {~D[2024-11-02], ~D[2024-10-01]},
        {~D[2024-12-01], ~D[2024-10-01]},
        {~D[2024-12-02], ~D[2024-10-01]}
      ]
      |> Enum.each(fn {value, expected_result} ->
        result = DateTimeHelper.beginning_of_quarter(value)

        assert result == expected_result,
          message:
            "DateTimeHelper.beginning_of_quarter(#{inspect(value)}) = #{inspect(result)} but expected #{inspect(expected_result)}"
      end)
    end

    test "beginning_of_year" do
      [
        {~D[2024-01-01], ~D[2024-01-01]},
        {~D[2024-01-02], ~D[2024-01-01]},
        {~D[2024-02-01], ~D[2024-01-01]},
        {~D[2024-02-02], ~D[2024-01-01]},
        {~D[2024-11-02], ~D[2024-01-01]}
      ]
      |> Enum.each(fn {value, expected_result} ->
        result = DateTimeHelper.beginning_of_year(value)

        assert result == expected_result,
          message:
            "DateTimeHelper.beginning_of_year(#{inspect(value)}) = #{inspect(result)} but expected #{inspect(expected_result)}"
      end)
    end
  end
end
