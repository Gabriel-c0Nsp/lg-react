local config = require("modules.config")
local file_exist = require("modules.utils.check_file_exist")
local colors = require("modules.utils.colors")
local validate_input = require("modules.utils.validate_input")

local M = {}
local config_file = config.open_config()
local config_values = config.get_config_values(config_file)

--[[
  Example:
    lg g <component_name>
    lg generate <component_name>
    lg g <component_name> <path>
    lg generate <component_name> <path>
]]
function M.generate_component(component_name, path)
	path = path or "./"

	-- Checks if "component_name" has a custom extension
	local has_custom_extension = component_name:match("%.[%w]+$")
	local full_name = has_custom_extension and component_name or (component_name .. "." .. config_values.extension)

	-- Checks if "path" ends with a slash and, if not, adds one
	if path:sub(-1) ~= "/" then
		path = path .. "/"
	end

	-- Creates the directory, if necessary
	os.execute("mkdir -p " .. path)

	-- TODO: Add the component template depending on the extension
	local component = [[
  ]]

	if not file_exist(full_name) then
		local component_file = io.open(path .. "/" .. full_name, "w")
		if not component_file then
			print("ERROR: Unable to create component file")
			return nil
		end

		component_file:write(component)
		component_file:close()
	else
		print(colors.yellow .. "ALERT! File already exists" .. colors.reset)
		local valid_options = { "y", "n" }
		local answer

		repeat
			print("Do you want to overwrite it? (y/N)")
			answer = io.read()
			answer = answer:lower()

			if answer == "" then
				answer = "n"
			end

			if not validate_input(answer, valid_options) then
				print(colors.red .. "Invalid input. Please try again." .. colors.reset)
			end
		until validate_input(answer, valid_options)

		if answer == "y" then
			local component_file = io.open(path .. "/" .. full_name, "w")

			if not component_file then
				print("ERROR: Unable to create component file")
				return nil
			end

			component_file:write(component)
			component_file:close()
		else
			print(colors.yellow .. "Operation canceled" .. colors.reset)
		end
	end
end

--[[
  Example:
    lg g p<directory_name>
    lg generate p<directory_name>
    lg g page<directory_name>
    lg generate page<directory_name>
]]
function M.generate_page(path)
	path = path or "./"

	if path:sub(-1) == "/" then
		path = path:sub(1, -2)
	end

	os.execute("mkdir -p " .. path)
	os.execute("touch " .. path .. "/page." .. config_values.extension)

	-- TODO: Add the page template depending on the extension
	local page = [[
  ]]

	local page_file = io.open(path .. "/page." .. config_values.extension, "w")

	if not page_file then
		print("ERROR: Unable to create page file")
		return nil
	end

	page_file:write(page)
	page_file:close()
end

config.close_config(config_file)
return M
