defmodule AngenWeb.Api.GameJSON do
  @moduledoc """

  """

  @doc """
  Renders a list of models.
  """
  def create_success(%{id: id}) do
    %{result: "Match created", id: id}
  end

  def create_failure(_) do
    %{result: "Creation failure"}
  end

  def update_success(_) do
    %{result: "Match updated"}
  end

  def update_failure(_) do
    %{result: "Update failed"}
  end
end
