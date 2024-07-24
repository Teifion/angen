defmodule AngenWeb.Api.GameJSON do
  @moduledoc """

  """

  @doc """
  Renders a list of models.
  """
  def create_match(%{match: match}) do
    %{result: "Match created", match: match}
  end
end
