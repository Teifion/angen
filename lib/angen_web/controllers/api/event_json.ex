defmodule AngenWeb.Api.EventJSON do
  @moduledoc """

  """

  @doc """
  Renders a list of models.
  """
  def success(%{count: 0}) do
    %{result: "No events created"}
  end

  def success(%{count: count}) do
    %{result: "Event(s) created", count: count}
  end
end
