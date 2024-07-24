defmodule AngenWeb.Api.TokenJSON do
  @moduledoc """

  """

  @doc """
  Renders a list of models.
  """
  def request_token(%{token: token}) do
    %{result: "Token", token: token}
  end

  @doc """
  Renders an error
  """
  def simple_error(%{reason: reason}) do
    %{reason: reason, result: "Error"}
  end
end
