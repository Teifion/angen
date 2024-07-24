defmodule AngenWeb.Api.EventJSON do
  @moduledoc """

  """

  @doc """
  Renders a list of models.
  """
  def create_event(%{event: event}) do
    %{result: "Event created", event: event}
  end
end
