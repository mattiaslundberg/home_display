import Config
config :home_display, :main_scene, HomeDisplay.Scene.MainMock
config :home_display, :influx_module, HomeDisplay.Reporters.InfluxConnectionMock

config :ex_unit, assert_receive_timeout: 200
