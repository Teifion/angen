defmodule Angen.Settings.ServerSettings do
  @moduledoc false
  import Teiserver.Settings, only: [add_server_setting_type: 1]

  @spec create_server_settings() :: any()
  def create_server_settings do
    data_retention()

    add_server_setting_type(%{
      key: "allow_manual_user_registration",
      label: "Allow manual user registration",
      section: "Registration",
      type: "boolean",
      default: true
    })

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
      key: "max_age_user_events",
      label: "Max user event age",
      section: "Data retention",
      type: "integer",
      default: 90,
      description: "The maximum age (in days) for user telemetry events."
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
