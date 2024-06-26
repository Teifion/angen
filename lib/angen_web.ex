defmodule AngenWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use AngenWeb, :controller
      use AngenWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(css js assets webfonts fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: AngenWeb.Layouts]

      import Plug.Conn
      import AngenWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {AngenWeb.Layouts, :app}

      import Angen.Account.AuthLib,
        only: [
          allow?: 2,
          allow_any?: 2,
          allow_all?: 2,
          mount_require_all: 2,
          mount_require_any: 2
        ]

      alias Angen.Helper.StylingHelper
      import Angen.Helper.StringHelper, only: [format_number: 1]

      defguard is_connected?(socket) when socket.transport_pid != nil
      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component
      import AngenWeb.CoreComponents

      alias Angen.Helper.StylingHelper
      import Angen.Helper.StringHelper, only: [format_number: 1]
      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      alias Angen.Helper.StylingHelper
      import Angen.Helper.StringHelper, only: [format_number: 1]
      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component
      import AngenWeb.CoreComponents

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import AngenWeb.{CoreComponents, NavComponents, BootstrapComponents}
      import AngenWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      import Angen.Helper.TimexHelper,
        only: [represent_minutes: 1, date_to_str: 1, date_to_str: 2]

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: AngenWeb.Endpoint,
        router: AngenWeb.Router,
        statics: AngenWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
