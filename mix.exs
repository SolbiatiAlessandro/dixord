defmodule Dixord.MixProject do
  use Mix.Project

  def project do
    [
      app: :dixord,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Dixord.Application, []},
      extra_applications: [:logger, :runtime_tools],
      env: [
        guests_profile_images: %{
          red: "https://discordapp.com/assets/1cbd08c76f8af6dddce02c5138971129.png",
          blue: "https://discordapp.com/assets/6debd47ed13483642cf09e832ed0bc1b.png",
          yellow: "https://discordapp.com/assets/0e291f67c9274a1abdddeb3fd919cbaa.png",
          green: "https://discordapp.com/assets/dd4dbc0016779df1378e7812eabaa04d.png",
          grey: "https://discordapp.com/assets/322c936a8c8be1b803cd94861bdfa868.png"
        }
      ]
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
      {:phoenix, "~> 1.4.4"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:excoveralls, "~> 0.7.0", only: [:test, :dev]},
      {:ex_doc, "~> 0.21"},
	  {:phoenix_live_view, "~> 0.11.1"},
      {:floki, ">= 0.0.0", only: :test},
      {:pow, "~> 1.0.20"},
      {:uuid, "~> 1.1"},
	  {:surface, "~> 0.1.0-alpha.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
