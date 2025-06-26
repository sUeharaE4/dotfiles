-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'AdventureTime'


-- config should be reload when the config file changes
config.automatically_reload_config = true
wezterm.on('window-config-reloaded', function(window, pane)
  wezterm.log_info 'the config was reloaded for this window!'
end)

-- update
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

-- scroll backline
config.scrollback_lines = 3000

-- ime
config.use_ime = true

-- exit
config.exit_behavior = 'CloseOnCleanExit'


-- This is where you actually apply your config choices
config.color_scheme = "Vs Code Dark+ (Gogh)"

-- background
config.window_background_opacity = 0.95
config.macos_window_background_blur = 10

-- font related
config.font_size=16
config.font = wezterm.font(
  -- "Moralerspace Argon HWNF",
  "JetBrains Mono",
  {
    stretch = 'Normal',
    weight = 'Regular',
    bold = false,
    italic = false,
  }
)
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.text_background_opacity = 0.95
config.font_size = 16
config.cell_width = 1.0
config.line_height = 1.0
config.use_cap_height_to_scale_fallback_fonts = true


-- This increases color saturation by 50%
config.foreground_text_hsb = {
 hue = 1.0,
 saturation = 1.0,
 brightness = 1.2,
}

-- tab
-- window related
-- config.window_frame = {
--   inactive_titlebar_bg = "#44475A",
--   active_titlebar_bg = "#BD93F9",
--   inactive_titlebar_fg = "#44475A",
--   active_titlebar_fg = "#F8F8F2",
--   inactive_titlebar_border_bottom = "#282A36",
--   active_titlebar_border_bottom = "#282A36",
--   button_fg = "#44475A",
--   button_bg = "#282A36",
--   button_hover_fg = "#F8F8F2",
--   button_hover_bg = "#282A36",
-- }
config.window_padding = {
 left = 5,
 right = 5,
 top = 10,
 bottom = 5,
}
config.window_background_gradient = {
  -- Can be "Vertical" or "Horizontal".  Specifies the direction
  -- in which the color gradient varies.  The default is "Horizontal",
  -- with the gradient going from left-to-right.
  -- Linear and Radial gradients are also supported; see the other
  -- examples below
  -- orientation = "Vertical",
  orientation = { Linear = { angle = -50.0 } },

  -- Specifies the set of colors that are interpolated in the gradient.
  -- Accepts CSS style color specs, from named colors, through rgb
  -- strings and more
  -- colors = {
  --      "#0f0c29",
  --      "#302b63",
  --      "#24243e",
  --},
  colors = {
    "#0f0c29",
    "#282a36",
    "#343746",
    "#3a3f52",
    "#343746",
    "#282a36",
  },
  -- colors = { "Inferno" },

  -- Instead of specifying `colors`, you can use one of a number of
  -- predefined, preset gradients.
  -- A list of presets is shown in a section below.
  -- preset = "Warm",

  -- Specifies the interpolation style to be used.
  -- "Linear", "Basis" and "CatmullRom" as supported.
  -- The default is "Linear".
  interpolation = "Linear",

  -- How the colors are blended in the gradient.
  -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
  -- The default is "Rgb".
  blend = "Rgb",

  -- To avoid vertical color banding for horizontal gradients, the
  -- gradient position is randomly shifted by up to the `noise` value
  -- for each pixel.
  -- Smaller values, or 0, will make bands more prominent.
  -- The default value is 64 which gives decent looking results
  -- on a retina macbook pro display.
  noise = 64,

  -- By default, the gradient smoothly transitions between the colors.
  -- You can adjust the sharpness by specifying the segment_size and
  -- segment_smoothness parameters.
  -- segment_size configures how many segments are present.
  -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
  -- 1.0 is a soft edge.

  segment_size = 11,
  segment_smoothness = 1.0,
}

local keybind = require 'keybinds'
-- config.disable_default_key_bindings = true
config.keys = keybind.keys
config.key_tables = keybind.key_tables
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

-- and finally, return the configuration to wezterm
return config
