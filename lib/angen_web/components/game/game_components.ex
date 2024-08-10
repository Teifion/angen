defmodule AngenWeb.Account.GameComponents do
  @moduledoc false
  use AngenWeb, :component
  import AngenWeb.{NavComponents}

  @doc """
  <AngenWeb.Account.GameComponents.filter_bar active="active" />

  <AngenWeb.Account.GameComponents.filter_bar active="active">
    Right side content here
  </AngenWeb.Account.GameComponents.filter_bar>
  """
  attr :selected, :string, default: "list"
  slot :inner_block, required: false

  def filter_bar(assigns) do
    ~H"""
    <div class="row section-menu">
      <div class="col">
        <.section_menu_button_url
          colour="info"
          icon={StylingHelper.icon(:list)}
          active={@selected == "list"}
          url={~p"/admin/game"}
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
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
