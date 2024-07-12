defmodule AngenWeb.Logging.GameComponents do
  @moduledoc false
  use AngenWeb, :component
  import AngenWeb.{NavComponents, BootstrapComponents}

  @doc """
  <AngenWeb.Logging.GameComponents.filter_bar unit={@unit} limit={@limit} display_mode={@display_mode}>
    CONTENT
  </AngenWeb.Logging.GameComponents.filter_bar
  """
  attr :unit, :string, default: "day"
  attr :mode, :string, default: "table"
  attr :selected, :string, default: nil
  slot :inner_block, required: true

  def filter_bar(assigns) do
    ~H"""
    <div class="row section-menu">
      <div class="col">
        <.section_menu_button_url
          colour="info"
          icon="clock"
          active={@selected == "now"}
          url={~p"/admin/logging/game/now"}
        >
          Now
        </.section_menu_button_url>

        <.section_menu_button_url
          colour="info"
          icon="waveform"
          active={@selected == "today"}
          url={~p"/admin/logging/game/show/day/today"}
        >
          Today
        </.section_menu_button_url>

        <.section_menu_button_url
          colour="info"
          icon="list"
          active={@selected == "history"}
          url={~p"/admin/logging/game"}
        >
          History
        </.section_menu_button_url>

        <.section_menu_button_url
          :if={@selected == "show"}
          colour="info"
          icon={StylingHelper.icon(:detail)}
          active={@selected == "show"}
        >
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
  <AngenWeb.Logging.GameComponents.overview_detail data={@data} />
  """
  attr :data, :map, required: true

  def overview_detail(assigns) do
    assigns = assigns
      |> assign(:groups, ["rated", "team_count", "team_size", "type"])

    ~H"""
    <div class="row">
      <div class="mt-4 col-md-6 col-lg-4 col-xl-3">
        <.card>
          <h4>Totals</h4>
          <table class="table table-sm">
            <tbody>
              <tr>
                <td>Total games</td>
                <td><%= format_number(@data["totals"]["raw_count"]) %></td>
              </tr>
              <tr>
                <td>Total players</td>
                <td><%= format_number(@data["totals"]["player_count"]) %></td>
              </tr>
              <tr>
                <td>Player hours</td>
                <td><%= format_number(@data["totals"]["player_hours"]) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>

      <div class="mt-4 col-md-6 col-lg-4 col-xl-3" :for={group <- @groups}>
        <% values = Map.keys(@data["matches"]["raw_counts"][group]) %>

        <.card>
          <h4><%= String.capitalize(group) %></h4>
          <table class="table table-sm">
            <thead>
              <tr>
                <th>&nbsp;</th>
                <th>Game count</th>
                <th>Player count</th>
                <th>Player hours</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={value <- values}>
                <td><%= value %></td>
                <td><%= format_number(@data["matches"]["raw_counts"][group][value]) %></td>
                <td><%= format_number(@data["matches"]["player_counts"][group][value]) %></td>
                <td><%= format_number(@data["matches"]["player_hours"][group][value]) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>
    </div>

    <AngenWeb.Logging.GameComponents.start_times_row data={@data} />

    <AngenWeb.Logging.GameComponents.by_duration_row data={@data} />



    <div class="row">
      <div class="mt-4 col-md-6 col-lg-4 col-xl-3" :for={{setting_key, setting_data} <- @data["settings"]}>
        <% setting_values = Map.keys(setting_data["raw_count"]) %>

        <.card>
          <h4><%= String.capitalize(setting_key) %></h4>
          <table class="table table-sm">
            <thead>
              <tr>
                <th>&nbsp;</th>
                <th>Game count</th>
                <th>Player count</th>
                <th>Player hours</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={value <- setting_values}>
                <td><%= value %></td>
                <td><%= format_number(setting_data["raw_count"][value]) %></td>
                <td><%= format_number(setting_data["player_counts"][value]) %></td>
                <td><%= format_number(setting_data["player_hours"][value]) %></td>
              </tr>
            </tbody>
          </table>
        </.card>
      </div>
    </div>
    """
  end


  @doc """
  <AngenWeb.Logging.GameComponents.start_times_row data={@data} />
  """
  attr :data, :map, required: true

  def start_times_row(assigns) do
    assigns = assigns
      |> assign(:start_buckets, 0..23 |> Enum.map(fn v -> ["#{v}.0", "#{v}.1", "#{v}.2", "#{v}.3"] end) |> List.flatten)
      |> assign(:short_start_buckets, 0..23)

    ~H"""
    <div class="row" id="start-times-row">
      <div class="col mt-4">
        <.card>
          Heatmap of start hour (all times are UTC). Each block is 15 minutes.
          <table class="table table-sm empty-cells">
            <thead>
              <tr>
                <th>&nbsp;</th>
                <th :for={b <- @short_start_buckets} colspan="4" style="border-left: 1px solid #AAA;"><%= b %></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Game count</td>
                <% values = for b <- @start_buckets, do: @data["start_times"]["raw_count"] |> Map.get(to_string(b), 0) %>
                <AngenWeb.Logging.GameComponents.heatmap_row values={values} minimum={0} print={false} />
              </tr>
            </tbody>
          </table>
        </.card>
      </div>
    </div>
    """
  end

  @doc """
  <AngenWeb.Logging.GameComponents.by_duration_row data={@data} />
  """
  attr :data, :map, required: true

  def by_duration_row(assigns) do
    assigns = assigns
      |> assign(:duration_buckets, 1..12 |> Enum.map(fn v -> v * 5 end))

    ~H"""
    <div class="row">
      <div class="col mt-4">
        <.card>
          Counts grouped by duration (rounds downwards), anything larger than the largest value is placed in the largest value. Durations are in minutes.
          <table class="table table-sm">
            <thead>
              <tr>
                <th>&nbsp;</th>
                <th :for={b <- @duration_buckets}><%= b %></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Game count</td>
                <% values = for b <- @duration_buckets, do: @data["duration_minutes"]["raw_count"] |> Map.get(to_string(b), 0) %>
                <AngenWeb.Logging.GameComponents.heatmap_row values={values} minimum={0} />
              </tr>
              <tr>
                <td>Player count</td>
                <% values = for b <- @duration_buckets, do: @data["duration_minutes"]["player_counts"] |> Map.get(to_string(b), 0) %>
                <AngenWeb.Logging.GameComponents.heatmap_row values={values} minimum={0} />
              </tr>
              <tr>
                <td>Player hours</td>
                <% values = for b <- @duration_buckets, do: @data["duration_minutes"]["player_hours"] |> Map.get(to_string(b), 0) %>
                <AngenWeb.Logging.GameComponents.heatmap_row values={values} minimum={0} />
              </tr>
            </tbody>
          </table>
        </.card>
      </div>
    </div>
    """
  end

  @doc """
  <AngenWeb.Logging.GameComponents.data_detail data={@data} />
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

  @doc """
  <AngenWeb.Logging.GameComponents.heatmap_row values={@values} />

  <AngenWeb.Logging.GameComponents.heatmap_row values={@values} maximum={123} minimum={0} />
  """

  attr :values, :list, required: true
  attr :maximum, :integer, default: nil
  attr :minimum, :integer, default: nil
  attr :print, :boolean, default: true

  def heatmap_row(assigns) do
    assigns = assigns
      |> assign(:maximum, assigns[:maximum] || Enum.max(assigns[:values]))
      |> assign(:minimum, assigns[:minimum] || Enum.min(assigns[:values]))

    ~H"""
    <AngenWeb.Logging.GameComponents.heatmap_cell value={v} minimum={@minimum} maximum={@maximum} print={@print} :for={v <- @values} />
    """
  end

  @doc """
  <AngenWeb.Logging.GameComponents.heatmap_cell value={50} minimum={0} maximum={123} />
  """
  attr :value, :integer, required: true
  attr :maximum, :integer, default: nil
  attr :minimum, :integer, default: nil
  attr :print, :boolean, default: true

  def heatmap_cell(assigns) do
    colour = heatmap_cell_colour(assigns[:value], assigns[:minimum], assigns[:maximum])

    assigns = assigns
      |> assign(:colour, colour)

    ~H"""
    <td class="heatmap-cell" style={"background-color: ##{@colour};"}><%= if @print, do: format_number(@value) %></td>
    """
  end

  def heatmap_cell_colour(value, minimum, maximum) do
    percentage = max(value, minimum) / max(maximum, 1)

    [
      percentage * 255,
      percentage * 25,
      percentage * 25
    ]
    |> Enum.map_join(fn colour ->
      colour
      |> round
      |> Integer.to_string(16)
      |> to_string
      |> String.pad_leading(2, "0")
    end)
  end
end
