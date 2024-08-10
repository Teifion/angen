defmodule AngenWeb.Api.AccountJSON do
  @moduledoc """

  """

  @doc """
  Renders a list of models.
  """
  def create_success(%{user: %{id: id, name: name}}) do
    %{result: "User created", id: id, name: name}
  end

  def create_failure(_) do
    %{result: "Creation failure"}
  end
end
