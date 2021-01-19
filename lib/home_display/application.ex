defmodule HomeDisplay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HomeDisplay.Supervisor]
    main_viewport_config = Application.get_env(:home_display, :viewport)

    children =
      [
        # Children for all targets
        {Scenic, viewports: [main_viewport_config]}
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def children(:host) do
    []
  end

  def children(_target) do
    []
  end

  def target() do
    Application.get_env(:home_display, :target)
  end
end
