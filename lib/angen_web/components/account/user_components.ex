defmodule AngenWeb.Account.UserComponents do
  @moduledoc false
  use AngenWeb, :component
  import AngenWeb.{NavComponents}

  @doc """
  <AngenWeb.Account.UserComponents.filter_bar active="active" />
  """
  attr :selected, :string, default: "list"

  def filter_bar(assigns) do
    ~H"""
    <div class="row section-menu">
      <div class="col">
        <.section_menu_button_url
          colour="info"
          icon="list"
          active={@selected == "list"}
          url={~p"/admin/accounts"}
        >
          List
        </.section_menu_button_url>

        <.section_menu_button_url
          :if={@selected == "show"}
          colour="info"
          icon={StylingHelper.icon(:detail)}
          active={@selected == "show"}
          url="#"
        >
          Show
        </.section_menu_button_url>
      </div>
    </div>
    """
  end
end
