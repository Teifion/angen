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
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "~> 0.20.5"},
      {:floki, ">= 0.34.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},

      # Extra deps
      {:ecto_psql_extras, "~> 0.7"},
      {:logger_file_backend, "~> 0.0.10"},
      {:timex, "~> 3.7.5"},
      {:argon2_elixir, "~> 3.0"},
      {:oban, "~> 2.17"},
      {:phoenix_pubsub, "~> 2.0"},
      {:excoveralls, "~> 0.15.3", only: :test, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:dart_sass, "~> 0.6"},
      {:tzdata, "~> 1.1"},
      {:etop, "~> 0.7.0"},
      {:fontawesome_icons, "~> 0.0.4"},
      {:guardian, "~> 2.1"},
      {:bodyguard, "~> 2.4"},
      {:thousand_island, "~> 1.3"},
      {:cachex, "~> 3.6"},
      {:ex_json_schema, "~> 0.10.2"},

      # We're pointing it at a specific git branch most of the time but
      # when developing locally we'll want to use a relative
      # reference
      # {:teiserver, git: "https://github.com/teifion/teiserver.git", branch: "0.0.4"}
      # {:teiserver,
      #  git: "https://github.com/teifion/teiserver.git",
      #  ref: "de29181fbc81141fbc53726d06432540acf33476"}
      {:teiserver, path: "../teiserver"}
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
