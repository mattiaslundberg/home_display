# HomeDisplay

Displaying useful information on a [Inky pHAT](https://shop.pimoroni.com/products/inky-phat?variant=12549254217811) and from a raspberry pi 3.

## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:

- Setup PI and pHAT
- Set `HOME_DISPLAY_WIFI_SSID`, `HOME_DISPLAY_WIFI_PSK` and `HOME_DISPLAY_CALENDAR_URLS`
- `export MIX_TARGET=rpi3` or prefix every command with
  `MIX_TARGET=rpi3`.
- Install dependencies with `mix deps.get`
- Create firmware with `mix firmware`
- Burn to an SD card with `mix firmware.burn`
- Update with `mix upload home-display.local`

## Learn more

- Official docs: https://hexdocs.pm/nerves/getting-started.html
- Official website: https://nerves-project.org/
- Forum: https://elixirforum.com/c/nerves-forum
- Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
- Source: https://github.com/nerves-project/nerves
