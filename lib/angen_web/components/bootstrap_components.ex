defmodule AngenWeb.BootstrapComponents do
  @moduledoc false

  use Phoenix.Component
  # import AngenWeb.NavComponents

  @doc """
  <AngenWeb.BootstrapComponents.dropdown items={@items} />
  """
  attr :items, :list, required: true
  attr :label, :string, required: true
  # attr :colour, :string, default: "secondary"
  # attr :active, :boolean, default: false
  # slot :inner_block, required: true
  # attr :rest, :global, doc: "the arbitrary HTML attributes to add to the button"
  def dropdown(assigns) do
    ~H"""
    <div class="dropdown d-inline-block">
      <button
        class="btn btn-secondary dropdown-toggle"
        type="button"
        data-bs-toggle="dropdown"
        aria-expanded="false"
      >
        <%= @label %>
      </button>
      <ul class="dropdown-menu">
        <.dropdown_item
          :for={item <- @items}
          label={item.label}
          click={item.click}
          selected={item[:selected]}
        />
      </ul>
    </div>
    """
  end

  @doc """
  <AngenWeb.BootstrapComponents.dropdown unit={@unit} limit={@limit} display_mode={@display_mode} />

  Requires one of: :click, :url
  """
  attr :click, :string, default: nil
  attr :url, :string, default: nil
  attr :selected, :boolean, default: false
  attr :label, :string, required: true

  def dropdown_item(%{click: _} = assigns) do
    ~H"""
    <li>
      <span
        class={["dropdown-item cursor-pointer", @selected && "bg-primary_transparent", ""]}
        phx-click={@click}
      >
        <%= @label %>
      </span>
    </li>
    """
  end

  def dropdown_item(%{url: _} = assigns) do
    ~H"""
    <li><a class="dropdown-item" href={@url}><%= @label %></a></li>
    """
  end

  @doc """
  <AngenWeb.BootstrapComponents.card>
    CONTENT
  </AngenWeb.BootstrapComponents.card>
  """
  slot :inner_block, required: true
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  def card(assigns) do
    ~H"""
    <div
      class={[
        "card",
        @class
      ]}
      {@rest}
    >
      <div class="card-body">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  https://getbootstrap.com/docs/5.3/components/badge/#pill-badges

  <AngenWeb.BootstrapComponents.pill>
    CONTENT
  </AngenWeb.BootstrapComponents.pill>
  """
  slot :inner_block, required: true
  attr :class, :string, default: "text-bg-primary"
  attr :rest, :global, include: ~w(disabled)

  def pill(assigns) do
    ~H"""
    <div
      class={[
        "badge rounded-pill",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
