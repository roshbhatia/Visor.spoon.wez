# Visor.spoon

An unofficial [Spoon](https://www.hammerspoon.org/go/#spoonsintro) for [Hammerspoon](https://www.hammerspoon.org/) to create
iTerm 2 reminiscent hotkey windows (in the Linux tradition of Guake/Yakuake/etc.) for terminals that don't support it natively,
when possible.

Currently, `Visor.spoon` supports the WezTerm terminal.

## Usage

If Hammerspoon and [WezTerm](https://wezfurlong.org/wezterm/) are already installed, then setting up Visor is pretty straight forward:

1. Clone this repo in to your Hammerspoon Spoons folder
2. Load the spoon in your Hammerspoon `init.lua`
3. Call the configuration method on the spoon with your desired options
4. Call `:start()` on the spoon.

### Copy-paste instructions

First, we clone the repository:

```console
# Clone the repository in to your Spoons folder
$ mkdir -p "$HOME/.hammerspoon/Spoons"
$ git clone https://github.com/dljsjr/Visor.spoon.git "$HOME/.hammerspoon/Spoons/Visor.spoon"
```

Next, we need to add Visor to our Hammerspoon `init.lua`:

```lua
-- Add the following to $HOME/.hammerspoon/init.lua
hs.loadSpoon("Visor")

spoon.Visor:configureForWezTerm({
  height = 0.4, -- 1.0 is full height (0.4 = 40% of screen)
})

-- Currently the only action provided by Visor is toggling the terminal.
-- This example binds it to Alt+Enter. See the Hammerspoon documentation
-- for more information on binding keys to understand e.g. using modifiers
-- like `ctrl` or `cmd` or `opt` or `shift`.
spoon.Visor:bindHotKeys {
  toggleTerminal = { {"alt"}, "return" }
}

-- Use `spoon.Visor.DisplayOptions.PrimaryDisplay` to always show the window on the display
-- configured as the primary desktop display in System Settings.
--
-- Use `spoon.Visor.DisplayOptions.ActiveDisplay` to have the terminal window show on the
-- display that contains the currently focused window.
spoon.Visor:showOnDisplayBehavior(spoon.Visor.DisplayOptions.PrimaryDisplay)

-- `start()` must be called (using the colon syntax as a method) on the Spoon instance
-- to register the hotkey and set up the monitoring and introspection scaffolding for
-- spawning, reattaching to, and controlling the hotkey window.
spoon.Visor:start()
```
Reload your Hammerspoon config and you should be able to show/hide your new WezTerm drop-down window with the hotkey you configured
in your `init.lua`.

## WezTerm Configuration

For the visor window to be properly identified, add this to your `~/.config/wezterm/wezterm.lua`:

```lua
local wezterm = require("wezterm")

-- Detect and configure visor window
wezterm.on('window-config-reloaded', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  
  if appearance:match("visor") then
    window:set_title("VISOR")
    overrides.window_background_opacity = 0.9
  end
  
  window:set_config_overrides(overrides)
end)
```

## Aerospace Compatibility

If you use [Aerospace](https://github.com/nikitabobko/AeroSpace) window manager, add this to your Aerospace config to make the visor float:

```toml
[[on-window-detected]]
run = ["layout floating"]

[on-window-detected.if]
app-id = "org.wez.wezterm.visor"
```

Also remove any existing `alt-enter` binding from your Aerospace config to avoid conflicts.

## Known Limitations

WezTerm does not currently provide an always-on-top window config. And Hammerspoon can't reliably provide a way to force an app's window to
remains always-on-top when not focused, without doing crazy things like injecting code. The visor window will auto-hide when it loses focus instead.

## License

MIT - <https://opensource.org/licenses/MIT>
