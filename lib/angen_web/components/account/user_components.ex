defmodule AngenWeb.Account.UserComponents do
  @moduledoc false
  use AngenWeb, :component
  import AngenWeb.{NavComponents}

  @doc """
  <AngenWeb.Account.UserComponents.filter_bar active="active" />

  <AngenWeb.Account.UserComponents.filter_bar active="active">
    Right side content here
  </AngenWeb.Account.UserComponents.filter_bar>
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
          url={~p"/admin/accounts"}
        >
          List
        </.section_menu_button_url>

        <.section_menu_button_url
          colour="info"
          icon={StylingHelper.icon(:new)}
          active={@selected == "new"}
          url={~p"/admin/accounts/user/new"}
        >
          New
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

        <.section_menu_button_url
          :if={@selected == "edit"}
          colour="info"
          icon={StylingHelper.icon(:edit)}
          active={@selected == "edit"}
          url="#"
        >
          Edit
        </.section_menu_button_url>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  <AngenWeb.Account.UserComponents.status_icon user={user} />
  """
  attr :user, :map, required: true

  def status_icon(%{user: %{data: user_data} = user} = assigns) do
    restrictions = user_data["restrictions"] || []

    ban_status =
      cond do
        Enum.member?(restrictions, "Permanently banned") -> "banned"
        Enum.member?(restrictions, "Login") -> "suspended"
        true -> ""
      end

    icons =
      [
        if(assigns.user.smurf_of_id != nil,
          do: {"primary", "fa-smurf"}
        ),
        if(Enum.member?(user.roles, "Smurfer"), do: {"info2", "fa-solid fa-split"}),
        if(ban_status == "banned",
          do: {"danger2", "fa-ban"}
        ),
        if(ban_status == "suspended",
          do: {"danger", "fa-suspend"}
        ),
        if(Enum.member?(restrictions, "All chat"),
          do: {"danger", "fa-mute"}
        ),
        if(Enum.member?(restrictions, "Warning reminder"),
          do: {"warning", "fa-warn"}
        ),
        if(Enum.member?(user.roles, "Trusted"), do: {"", "fa-solid fa-check"}),
        if(not Enum.member?(user.roles, "Verified"),
          do: {"info", "fa-solid fa-square-question"}
        )
      ]
      |> Enum.reject(&(&1 == nil))

    status_icon_list(%{icons: icons})
  end

  defp status_icon_list(assigns) do
    ~H"""
    <div :for={{colour, icon} <- @icons} class="d-inline-block">
      <i class={"fa-fw text-#{colour} #{icon}"}></i>
    </div>
    """
  end
end
