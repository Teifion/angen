defmodule Angen.Helper.StylingHelper do
  @moduledoc false
  # alias HTMLIcons

  @spec icon(atom) :: String.t()
  def icon(:report), do: "fa-signal"
  def icon(:up), do: "fa-level-up"
  def icon(:back), do: "fa-arrow-left"

  def icon(:list), do: "fa-bars"
  def icon(:show), do: "fa-eye"
  def icon(:search), do: "fa-search"
  def icon(:new), do: "fa-plus"
  def icon(:edit), do: "fa-wrench"
  def icon(:delete), do: "fa-trash"
  def icon(:export), do: "fa-download"
  def icon(:structure), do: "fa-cubes"
  def icon(:documentation), do: "fa-book"
  def icon(:chat), do: "fa-comment"

  def icon(:admin), do: "fa-user-crown"
  def icon(:moderation), do: "fa-gavel"

  def icon(:overview), do: "fa-expand-alt"
  def icon(:detail), do: "fa-file-alt"
  def icon(:user), do: "fa-user"

  def icon(:filter), do: "fa-filter"

  def icon(:summary), do: "fa-user-chart"

  def icon(:chart), do: "fa-chart-line"

  def icon(:day), do: "fa-calendar-day"
  def icon(:week), do: "fa-calendar-week"
  def icon(:month), do: "fa-calendar-range"
  def icon(:quarter), do: "fa-calendar"
  def icon(:year), do: "fa-circle-calendar"

  # Sections
  def icon(:logging), do: "fa-bars"
  def icon(:server_activity), do: "fa-monitor-heart-rate"
  def icon(:game_activity), do: "fa-swords"
  def icon(:audit), do: "fa-archive"

  @spec icon(atom, String.t()) :: String.t()
  def icon(icon_atom, fa_type), do: "fa-#{fa_type} #{icon(icon_atom)}"
end
