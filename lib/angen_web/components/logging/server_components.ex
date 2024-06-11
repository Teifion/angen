defmodule AngenWeb.Logging.ServerComponents do
  @moduledoc false
  use AngenWeb, :component
  import AngenWeb.{NavComponents, BootstrapComponents}

  @doc """
  <AngenWeb.Logging.ServerComponents.filter_bar unit={@unit} limit={@limit} display_mode={@display_mode}>
    CONTENT
  </AngenWeb.Logging.ServerComponents.filter_bar
  """
  attr :unit, :string, default: "day"
  attr :mode, :string, default: "table"
  attr :selected, :string, default: nil
  slot :inner_block, required: true

  def filter_bar(assigns) do
    ~H"""
    <div class="row section-menu">
      <div class="col">
        <.section_menu_button_url colour="info" icon="clock" active={@selected == "now"} url={~p"/admin/logging/server/now"}>
          Now
        </.section_menu_button_url>

        <.section_menu_button_url colour="info" icon="waveform" active={@selected == "today"} url={~p"/admin/logging/server/show/day/today"}>
          Today
        </.section_menu_button_url>

        <.section_menu_button_url colour="info" icon="list" active={@selected == "history"} url={~p"/admin/logging/server"}>
          History
        </.section_menu_button_url>

        <.section_menu_button_url colour="info" icon="server" active={@selected == "load"} url={~p"/admin/logging/server/load"}>
          Load
        </.section_menu_button_url>

        <.section_menu_button_url :if={@selected == "show"} colour="info" icon={StylingHelper.icon(:detail)} active={@selected == "show"}>
          Detail
        </.section_menu_button_url>
      </div>

      <div class="col">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  <AngenWeb.Logging.ServerComponents.overview_detail data={@data} />
  """
  attr :data, :map, required: true
  attr :events, :map, required: true
  def overview_detail(assigns) do
    ~H"""
    <div class="row mt-4">
      <div class="col">
        <.card>
          <h4>Stats</h4>
          <table class="table table-sm">
            <tbody>
              <tr>
                <td>Unique users</td>
                <td><%= @data["stats"]["unique_users"] %></td>
              </tr>
              <tr>
                <td>Unique players</td>
                <td><%= @data["stats"]["unique_players"] %></td>
              </tr>
              <tr>
                <td>Accounts created</td>
                <td><%= @data["stats"]["accounts_created"] %></td>
              </tr>

            </tbody>
          </table>
        </.card>
      </div>

      <div class="col">
        <.card>
          <h4>Peaks</h4>
          <table class="table table-sm">
            <tbody>
              <tr>
                <td>Player</td>
                <td><%= @data["peak_user_counts"]["player"] %></td>
              </tr>
              <tr>
                <td>Spectator</td>
                <td><%= @data["peak_user_counts"]["spectator"] %></td>
              </tr>
              <tr>
                <td>Lobby</td>
                <td><%= @data["peak_user_counts"]["lobby"] %></td>
              </tr>
              <tr>
                <td>Menu</td>
                <td><%= @data["peak_user_counts"]["menu"] %></td>
              </tr>
              <tr>
                <td>Bot</td>
                <td><%= @data["peak_user_counts"]["bot"] %></td>
              </tr>
              <tr style="font-weight: bold;">
                <td>Total (no bots)</td>
                <td><%= @data["peak_user_counts"]["total_non_bot"] %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>

      <div class="col">
        <.card>
          <h4>Time</h4>
          <table class="table table-sm">
            <tbody>
              <tr>
                <td>Player</td>
                <td><%= represent_minutes(@data["minutes"]["player"]) %></td>
              </tr>
              <tr>
                <td>Spectator</td>
                <td><%= represent_minutes(@data["minutes"]["spectator"]) %></td>
              </tr>
              <tr>
                <td>Lobby</td>
                <td><%= represent_minutes(@data["minutes"]["lobby"]) %></td>
              </tr>
              <tr>
                <td>Menu</td>
                <td><%= represent_minutes(@data["minutes"]["menu"]) %></td>
              </tr>
              <tr>
                <td>Bot</td>
                <td><%= represent_minutes(@data["minutes"]["bot"]) %></td>
              </tr>
              <tr style="font-weight: bold;">
                <td>Total (no bots)</td>
                <td><%= represent_minutes(@data["minutes"]["total_non_bot"]) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>
    </div>

    <div class="row mt-4">
      <div class="col">
        <.card>
          <h4>Server events</h4>
          <table class="table table-sm">
            <tbody>
              <tr :for={{event, count} <- @events["simple_server"] |> Enum.take(10)}>
                <td><%= event %></td>
                <td><%= StringHelper.format_number(count) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>

      <div class="col">
        <.card>
          <h4>Clientapp events</h4>
          <table class="table table-sm">
            <tbody>
              <tr :for={{event, count} <- @events["simple_clientapp"] |> Enum.take(10)}>
                <td><%= event %></td>
                <td><%= StringHelper.format_number(count) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>

      <div class="col">
        <.card>
          <h4>Anon events</h4>
          <table class="table table-sm">
            <tbody>
              <tr :for={{event, count} <- @events["simple_anon"] |> Enum.take(10)}>
                <td><%= event %></td>
                <td><%= StringHelper.format_number(count) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>

      <div class="col">
        <.card>
          <h4>Lobby events</h4>
          <table class="table table-sm">
            <tbody>
              <tr :for={{event, count} <- @events["simple_lobby"] |> Enum.take(10)}>
                <td><%= event %></td>
                <td><%= StringHelper.format_number(count) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>

      <div class="col">
        <.card>
          <h4>Match events</h4>
          <table class="table table-sm">
            <tbody>
              <tr :for={{event, count} <- @events["simple_match"] |> Enum.take(10)}>
                <td><%= event %></td>
                <td><%= StringHelper.format_number(count) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>
    </div>
    """
  end

  @doc """
  <AngenWeb.Logging.ServerComponents.data_detail data={@data} />
  """
  attr :data, :map, required: true
  def data_detail(assigns) do
    ~H"""
    <div class="row mt-4">
      <div class="col">
        <.card>
          <textarea rows="2" class="form-control monospace"><%= Jason.encode!(@data) %></textarea>
          <br />

          <textarea rows="60" class="form-control monospace"><%= Jason.encode!(@data, pretty: true) %></textarea>
        </.card>
      </div>
    </div>
    """
  end
end
