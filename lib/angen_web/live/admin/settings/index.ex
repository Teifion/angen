defmodule AngenWeb.Admin.SettingsLive.Index do
  @moduledoc false
  use AngenWeb, :live_view

  alias Teiserver.Settings

  @impl true
  def mount(_, _session, socket) do
    socket =
      socket
      |> assign(:tab, nil)
      |> assign(:site_menu_active, "settings")
      |> assign(:show_descriptions, false)
      |> assign(:temp_value, nil)
      |> assign(:selected_key, nil)
      |> load_setting_types
      |> load_server_settings

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _live_action, _params) do
    socket
    |> assign(:page_title, "Settings")
  end

  @impl true
  def handle_event("open-form", %{"key" => key}, %{assigns: assigns} = socket) do
    new_key =
      if assigns.selected_key == key do
        nil
      else
        key
      end

    current_value = Map.get(assigns.setting_values, key, assigns.setting_types[key].default)

    {:noreply,
     socket
     |> assign(:selected_key, new_key)
     |> assign(:temp_value, current_value)}
  end

  def handle_event(
        "reset-value",
        _,
        %{assigns: %{selected_key: key}} = socket
      ) do
    case Settings.get_server_setting(key) do
      nil ->
        :ok

      server_setting ->
        Settings.delete_server_setting(server_setting)
    end

    new_setting_values = Map.put(socket.assigns.setting_values, key, nil)

    {:noreply,
     socket
     |> assign(:setting_values, new_setting_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  def handle_event("set-" <> _, _, %{assigns: %{selected_key: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("set-true", _, %{assigns: %{selected_key: key}} = socket) do
    new_value = "true"
    Settings.set_server_setting_value(key, new_value)

    new_setting_values = Map.put(socket.assigns.setting_values, key, new_value)

    {:noreply,
     socket
     |> assign(:setting_values, new_setting_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  def handle_event("set-false", _, %{assigns: %{selected_key: key}} = socket) do
    new_value = "false"
    Settings.set_server_setting_value(key, new_value)

    new_setting_values = Map.put(socket.assigns.setting_values, key, new_value)

    {:noreply,
     socket
     |> assign(:setting_values, new_setting_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  def handle_event(
        "set-to",
        %{"setting" => %{"value" => new_value}},
        %{assigns: %{selected_key: key}} = socket
      ) do

    Settings.set_server_setting_value(key, new_value)

    new_setting_values = Map.put(socket.assigns.setting_values, key, new_value)

    {:noreply,
     socket
     |> assign(:setting_values, new_setting_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  defp load_setting_types(socket) do
    setting_types = Settings.list_server_setting_type_keys()
    |> Settings.list_server_setting_types()
    |> Map.new(fn t -> {t.key, t} end)

    setting_groups = setting_types
    |> Map.values
    |> Enum.group_by(fn s ->
      s.section
    end,
    fn
      s -> s.key
    end)

    socket
    |> assign(:setting_types, setting_types)
    |> assign(:setting_groups, setting_groups)
  end

  defp load_server_settings(socket) do
    setting_values = Settings.list_server_settings(limit: :infinity)
    |> Map.new(fn s ->
      {s.key, s.value}
    end)

    socket
    |> assign(:setting_values, setting_values)
  end
end
