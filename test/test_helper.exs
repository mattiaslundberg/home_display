ExUnit.start()

Mox.defmock(HomeDisplay.Scene.MainMock, for: HomeDisplay.Scene.Main)

Mox.defmock(HomeDisplay.Reporters.InfluxConnectionMock,
  for: HomeDisplay.Reporters.InfluxConnection
)
