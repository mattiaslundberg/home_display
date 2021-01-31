# HomeDisplay

Home Dashboard for display of some useful information.

Features:

 * Display of outside temperature (using SMHI API)
 * Display of important government information (using Krisinformation API)
 * Display of temperature readings, both locally (with a onewire sensor) and remotely (over HTTP API)
 
The system is running on a Raspberry PI 3A+ and is using an [Inky pHAT](https://shop.pimoroni.com/products/inky-phat?variant=12549254217811) as its main display.

## Tech

Build using Elixir and Nerves.

### Getting Started

To start your Nerves app:

- Setup PI and pHAT (PI 3A+ tested, should work on others with small modifications)
- Set `HOME_DISPLAY_WIFI_SSID`, `HOME_DISPLAY_WIFI_PSK` and `HOME_DISPLAY_CALENDAR_URLS`
- `export MIX_TARGET=rpi3` or prefix every command with
  `MIX_TARGET=rpi3`.
- Install dependencies with `mix deps.get`
- Create firmware with `mix firmware`
- Burn to an SD card with `mix firmware.burn`
- Update with `mix upload home-display.local`

### Learn more

- Official docs: https://hexdocs.pm/nerves/getting-started.html
- Official website: https://nerves-project.org/
- Forum: https://elixirforum.com/c/nerves-forum
- Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
- Source: https://github.com/nerves-project/nerves
