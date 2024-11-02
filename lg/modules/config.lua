local colors = require("modules.utils.colors")
local validate_input = require("modules.utils.validate_input")

local M = {}
function M.generate_config()
	local config, err = io.open("config.txt", "a+")

	if not config then
		print("ERROR: " .. err)
		return
	end

	return config
end

function M.close_config(config)
	config:close()
end

function M.get_config_values(config)
	local config_values = {
		style = "default",
		extension = "default",
	}

	-- returns the file pointer to the beginning
	config:seek("set")

	for line in config:lines() do
		-- ignore empty lines and comments
		if not line:match("^%s*$") and not line:match("^%s*%*") then
			-- capture the value of style in quotes
			local style = line:match('style%s*=%s*"(.-)"')
			if style then
				config_values.style = style
			end

			-- capture the value of extension in quotes
			local extension = line:match('extension%s*=%s*"(.-)"')
			if extension then
				config_values.extension = extension
			end
		end
	end

	return config_values
end

-- FIXME: Finish implementation
function M.update_config(config)
	print("THIS IS THE CONFIGURATION SCRIPT")
	print("\nPress 'Enter' to continue...")
	_ = io.read()

	-- define valid options
	local valid_extensions_input = { "1", "2", "3", "4" }
	local valid_style_input = { "1", "2" }

	-- clear screen
	os.execute("clear")

	local extension
	repeat
		print("What file extension do you want to use?")
		print(colors.yellow .. "\nOPTIONS (you can enter the corresponding number):" .. colors.reset)
		print("(1) js")
		print("(2) jsx")
		print("(3) ts")
		print("(4) tsx")

		io.write("--> ")
		extension = io.read()

		if not validate_input(extension, valid_extensions_input) then
			os.execute("clear")
			print(colors.red .. "Invalid input. Please try again." .. colors.reset)
		end
	until validate_input(extension, valid_extensions_input)

	os.execute("clear")

	local style
	repeat
		print("What type of style tool do you want to use?")
		print(colors.yellow .. "\nOPTIONS (you can enter the corresponding number):" .. colors.reset)
		print("(1) CSS")
		print("(2) Tailwind")

		io.write("--> ")
		style = io.read()

		if not validate_input(style, valid_style_input) then
			os.execute("clear")
			print(colors.red .. "Invalid input. Please try again." .. colors.reset)
		end
	until validate_input(style, valid_style_input)

	-- TODO: update config file
end
return M
