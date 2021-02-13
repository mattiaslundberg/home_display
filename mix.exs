defmodule HomeDisplay.MixProject do
  use Mix.Project

  @app :home_display
  @version "0.1.0"
  @all_targets [:rpi3]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HomeDisplay.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7.0", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},
      {:inky, "~> 1.0"},
      {:scenic, "~> 0.10"},
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.4.0"},
      {:instream, "~> 1.0"},
      {:ex_ical, "~> 0.2.0",
       git: "https://github.com/mattiaslundberg/ex_ical.git", branch: "support-language"},
      {:plug_cowboy, "~> 2.0"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:one_wire, "~> 0.1.0", git: "https://github.com/mattiaslundberg/one_wire.git"},
      {:floki, "~> 0.30.0"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},
      {:scenic_driver_inky, "~> 1.0.0", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi3, "~> 1.13", runtime: false, targets: :rpi3},

      # Test dependencies
      {:inky_host_dev, "~> 1.0", targets: :host, only: :dev},
      {:scenic_driver_glfw, "~> 0.10", targets: :host},
      {:mox, "~> 1.0", only: :test},
      {:stream_data, "~> 0.5", only: [:test, :dev]}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
