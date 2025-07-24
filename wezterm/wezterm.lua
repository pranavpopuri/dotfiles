local wezterm = require("wezterm")

local config = {}

config.automatically_reload_config = true
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Nord (Gogh)"
config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
config.font_size = 12.5

config.background = {
	{
		source = {
			File = "/Users/ppopuri/Downloads/790be3ec8e7601aef824515883a38649.jpg",
		},
		hsb = {
			hue = 1.0,
			saturation = 1.02,
			brightness = 0.25,
		},
		width = "100%",
		height = "100%",
	},
	{
		source = {
			Color = "#282c35",
		},
		width = "100%",
		height = "100%",
		opacity = 0.55,
	},
}

return config
