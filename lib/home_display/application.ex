defmodule HomeDisplay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HomeDisplay.Supervisor]
    location = Application.get_env(:home_display, :location, "98210")
    urls = Application.get_env(:home_display, :ical_urls, [])

    children =
      [
        # Children for all targets
        {HomeDisplay.Sources.WeatherPoller, location: location},
        {HomeDisplay.Sources.DatePoller, []},
        {HomeDisplay.Sources.KrisinformationPoller, []},
        {HomeDisplay.Sources.OneWireReader, []},
        {HomeDisplay.Sources.EventPoller, urls: urls},
        {Plug.Cowboy, scheme: :http, plug: HomeDisplay.Web.HttpRouter, options: [port: 4004]},
        HomeDisplay.Reporters.InfluxConnection
      ] ++ children(target()) ++ env_children(env())

    Supervisor.start_link(children, opts)
  end

  def children(:host) do
    []
  end

  def children(_target) do
    []
  end

  def env_children(:test) do
    []
  end

  def env_children(_) do
    main_viewport_config = Application.get_env(:home_display, :viewport)
    [{Scenic, viewports: [main_viewport_config]}]
  end

  def target do
    Application.get_env(:home_display, :target)
  end

  def env do
    Application.get_env(:home_display, :env)
  end
end
