defmodule Angen.Settings.ServerSettings do
  @moduledoc false
  import Teiserver.Settings, only: [add_server_setting_type: 1]

  @spec create_server_settings() :: any()
  def create_server_settings do
    data_retention()
    account_creation()
    security()
    telemetry()
  end

  defp telemetry do
    add_server_setting_type(%{
      key: "pure_collector_mode",
      label: "Pure collector mode",
      section: "Telemetry",
      type: "boolean",
      default: false,
      description:
        "When enabled the server will allow creation of functionality described in the Collector mode guide (documentation/guides/admin/collector_mode.md)."
    })
  end

  defp security() do
    add_server_setting_type(%{
      key: "require_tokens_to_persist_ip",
      label: "Require tokens to consistently use the same IP",
      section: "Security",
      type: "boolean",
      default: false,
      description:
        "When a token is created the IP used is tracked. If this option is enabled then the IP used to login via the token must match the token stored in the database. When enabled this can help prevent token theft but at the cost of needing users to re-acquire a token every time they change IP address."
    })
  end

  defp account_creation() do
    add_server_setting_type(%{
      key: "allow_registration_via_website",
      label: "Allow registration via website",
      section: "Registration",
      type: "boolean",
      default: false,
      description: "Allows creation of accounts via the website."
    })

    add_server_setting_type(%{
      key: "allow_guest_accounts",
      label: "Allow guest accounts",
      section: "Registration",
      type: "boolean",
      default: false,
      description: "Allows creation of temporary (guest) accounts."
    })
  end

  defp data_retention() do
    add_server_setting_type(%{
      key: "max_age_server_events",
      label: "Max server event age",
      section: "Data retention",
      type: "integer",
      default: 90,
      description: "The maximum age (in days) for server telemetry events."
    })

    add_server_setting_type(%{
      key: "max_age_lobby_events",
      label: "Max lobby event age",
      section: "Data retention",
      type: "integer",
      default: 90,
      description: "The maximum age (in days) for lobby telemetry events."
    })

    add_server_setting_type(%{
      key: "max_age_clientapp_events",
      label: "Max client event age",
      section: "Data retention",
      type: "integer",
      default: 90,
      description: "The maximum age (in days) for client application telemetry events."
    })

    add_server_setting_type(%{
      key: "max_age_match_events",
      label: "Max match event age",
      section: "Data retention",
      type: "integer",
      default: 90,
      description: "The maximum age (in days) for match telemetry events."
    })
  end
end
