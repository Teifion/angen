defmodule Angen.MixProject do
  use Mix.Project

  @source_url "https://github.com/Teifion/Angen"
  @version "0.0.1"

  def project do
    [
      app: :angen,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: "Middleware server using Teiserver",
      package: package()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Angen.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :iex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # These come with Phoenix
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "~> 0.20.5"},
      {:floki, ">= 0.34.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.5"},

      # Extra deps
      {:horde, "~> 0.9"},
      {:telemetry, "~> 1.2.1"},
      {:ecto_psql_extras, "~> 0.7"},
      {:oban, "~> 2.17"},
      {:phoenix_pubsub, "~> 2.0"},
      {:dart_sass, "~> 0.6"},
      {:tzdata, "~> 1.1"},
      {:etop, "~> 0.7.0"},
      {:fontawesome_icons, "~> 0.0.6"},
      {:thousand_island, "~> 1.3"},
      {:cachex, "~> 3.6"},
      {:ex_json_schema, "~> 0.10.2"},
      {:excoveralls, "~> 0.18.1", only: :test, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:progress_bar, "~> 3.0", only: [:dev, :test]},
      {:db_cluster, "~> 0.0.3"},
      {:uuid, "~> 1.1"},
      {:csv, "~> 3.2"},

      # We're pointing it at a specific git branch most of the time but
      # when developing locally we'll want to use a relative
      # reference or a specific git commit
      # {:teiserver, "~> 0.0.5"}
      {:teiserver,
       git: "https://github.com/teifion/teiserver.git",
       ref: "b07d3c6d71396d6863815954913244f77f973e7b"}
      # {:teiserver, path: "../teiserver"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "test.reset": ["ecto.drop --quiet", "test.setup"],
      "test.setup": ["ecto.create --quiet", "ecto.migrate --quiet"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild default"],
      "assets.deploy": [
        "esbuild default --minify",
        "sass dark --no-source-map --style=compressed",
        "sass light --no-source-map --style=compressed",
        "phx.digest"
      ],
      "test.ci": [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "test --raise"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Teifion Jordan"],
      licenses: ["Apache-2.0"],
      files: ~w(lib .formatter.exs mix.exs README* CHANGELOG* LICENSE*),
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url,
        "Discord" => "https://discord.gg/NmrSt9zw2p"
      }
    ]
  end
end
