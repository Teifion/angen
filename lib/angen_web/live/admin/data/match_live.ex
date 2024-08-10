defmodule AngenWeb.Admin.Data.MatchLive do
  @moduledoc false
  use AngenWeb, :live_view
  alias AngenWeb.Admin.Data.MatchLiveStruct
  alias Angen.ExportLib
  require Logger

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    changeset =
      MatchLiveStruct.changeset(%{
        start_date: Timex.today() |> Timex.to_datetime(),
        end_date: Timex.today() |> Timex.to_datetime() |> Timex.shift(days: 1)
      })

    socket
    |> assign(:site_menu_active, "data")
    |> assign(:submitted, false)
    |> assign(:export_id, nil)
    |> assign_form(changeset)
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "data")}
  end

  @impl true
  def handle_event("validate", %{"match_live_struct" => params}, socket) do
    changeset =
      MatchLiveStruct.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"match_live_struct" => params}, socket) do
    socket
    |> assign(:submitted, true)
    |> start_async(:generate_export, fn -> ExportLib.new_export(:matches, params) end)
    |> noreply
  end

  def handle_info(:export_complete, socket) do
    socket
    |> redirect(to: ~p"/admin/data/export/#{socket.assigns.export_id}")
    |> noreply
  end

  def handle_async(:generate_export, {:ok, export_id}, socket) do
    # We send ourselves the export complete to change page content
    # prior to redirecting ourselves
    send(self(), :export_complete)

    socket
    |> assign(:export_id, export_id)
    |> noreply
  end

  def handle_async(:generate_export, {:exit, reason}, socket) do
    Logger.error("Error exporting data. Got reason #{inspect(reason)}")

    socket
    |> assign(:export_error, reason)
    |> noreply
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

defmodule AngenWeb.Admin.Data.MatchLiveStruct do
  import Ecto.Changeset
  @types %{start_date: :naive_datetime, end_date: :naive_datetime}
  defstruct Map.keys(@types)

  def changeset(params) do
    {%__MODULE__{}, @types}
    |> cast(params, Map.keys(@types))
  end
end
