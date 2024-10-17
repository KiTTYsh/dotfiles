-- Function to search PATH for a program
function program_exists(program)
	local path_separator = package.config:sub(1,1) == "\\" and ";" or ":"
	for path in string.gmatch(os.getenv("PATH"), "[^" .. path_separator .. "]+") do
		local file_path = path .. "/" .. program
		local file = io.open(file_path, "r")
		if file then
			file:close()
			return true
		end
	end
	return false
end


local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'Windows NT (base16)'

config.font = wezterm.font 'Iosevka'
config.font_size = 12.0

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.initial_cols = 120
config.initial_rows = 30

-- Select default shell if running on Windows
if (package.config:sub(1,1) == '\\') then
	if program_exists('nu.exe') then
		config.default_prog = { 'nu.exe' }
	elseif program_exists('pwsh.exe') then
		config.default_prog = { 'pwsh.exe' }
	elseif program_exists('powershell.exe') then
		config.default_prog = { 'powershell.exe' }
	else
		config.default_prog = { 'cmd.exe' }
	end
end

return config
