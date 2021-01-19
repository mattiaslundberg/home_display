import Config

# Add configuration that is only needed when running on the host here.

config :home_display, :viewport, %{
  name: :main_viewport,
  default_scene: {HomeDisplay.Scene.Main, nil},
  size: {212, 104},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw
    }
  ]
}
