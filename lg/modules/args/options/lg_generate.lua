local config = require("modules.config.config")
local file_exist = require("modules.utils.check_file_exist")
local colors = require("modules.utils.colors")
local validate_input = require("modules.utils.validate_input")
local templates = require("modules.templates.templates")
local error_messages = require("modules.utils.output_logs")
local extract_path_name = require("modules.utils.extract_path_name")

local M = {}

local function get_component_template(component_name)
	local config_values = config.get_config_values()

	if config_values == nil then
		error_messages.critical_errors()["no_config_file"]()
		return
	end

	local component_template

	if config_values.extension == "js" then
		component_template = templates.component_template(component_name).component_js
	elseif config_values.extension == "jsx" then
		component_template = templates.component_template(component_name).component_jsx
	elseif config_values.extension == "ts" then
		component_template = templates.component_template(component_name).component_ts
	elseif config_values.extension == "tsx" then
		component_template = templates.component_template(component_name).component_tsx
	else
		error_messages.critical_errors()["invalid_extension"]()
	end

	return component_template
end

local function get_svg_template(svg_name, svg_content)
	local config_values = config.get_config_values()

	if config_values == nil then
		error_messages.critical_errors()["no_config_file"]()
		return
	end

	local svg_template

	if config_values.extension == "js" then
		svg_template = templates.svg_template(svg_name, svg_content).svg_js
	elseif config_values.extension == "jsx" then
		svg_template = templates.svg_template(svg_name, svg_content).svg_jsx
	elseif config_values.extension == "ts" then
		svg_template = templates.svg_template(svg_name, svg_content).svg_ts
	elseif config_values.extension == "tsx" then
		svg_template = templates.svg_template(svg_name, svg_content).svg_tsx
	else
		error_messages.critical_errors()["invalid_extension"]()
	end

	return svg_template
end

local function generate_css_file(component_name, path)
	local config_values = config.get_config_values()

	if config_values == nil then
		error_messages.critical_errors()["no_config_file"]()
		return
	end

	if config_values.style == "CSS" then
		os.execute("touch " .. path .. component_name .. ".css")
	end
end

M.generate_component = function(component_name, path)
	local config_values = config.get_config_values()

	if config_values == nil then
		error_messages.critical_errors()["no_config_file"]()
		return
	end

	path, component_name = extract_path_name(component_name, path, "for the component")

	if not path or not component_name then
		print(colors.red .. "ERROR: You need to provide a valid component name!" .. colors.reset)
		os.exit(1)
	end

	-- Checks if "component_name" has a custom extension
	local has_custom_extension = component_name:match("%.[%w]+$")
	local full_name = has_custom_extension and component_name or (component_name .. "." .. config_values.extension)

	-- subtract the extension from the component name
	component_name = component_name:match("(.+)%..+") or component_name

	os.execute("mkdir -p " .. path)

	local component = get_component_template(component_name)
	local component_file

	if not file_exist(path .. full_name) then
		component_file = io.open(path .. full_name, "w")
		generate_css_file(component_name, path)

		if not component_file then
			error_messages.errors()["unable_to_create"]("component file")
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
			io.write("--> ")
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
			component_file = io.open(path .. full_name, "w")
			generate_css_file(component_name, path)

			if not component_file then
				error_messages.errors()["unable_to_create"]("component file")
				return nil
			end

			component_file:write(component)
			component_file:close()
		else
			print(colors.yellow .. "Operation canceled" .. colors.reset)
		end
	end
end

M.generate_page = function(function_name, path)
	local config_values = config.get_config_values()

	if config_values == nil then
		error_messages.critical_errors()["no_config_file"]()
		return
	end

	path, function_name = extract_path_name(function_name, path)

	if not path or not function_name then
		print(colors.red .. "ERROR: You need to provide a valid function_name!" .. colors.reset)
	end

	local page = get_component_template(function_name)
	local page_path = path .. "page." .. config_values.extension

	if file_exist(page_path) then
		print(colors.yellow .. "ALERT! File already exists" .. colors.reset)
		local valid_options = { "y", "n" }
		local answer

		repeat
			print("Do you want to overwrite it? (y/N)")
			io.write("--> ")
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
			local page_file = io.open(path .. "page." .. config_values.extension, "w")
			generate_css_file("page", path)

			if not page_file then
				error_messages.errors()["unable_to_create"]("page file")
				return nil
			end

			page_file:write(page)
			page_file:close()
		else
			print(colors.yellow .. "Operation canceled" .. colors.reset)
		end
	else
		os.execute("mkdir -p " .. path)
		os.execute("touch " .. path .. "page." .. config_values.extension)

		local page_file = io.open(path .. "page." .. config_values.extension, "w")
		generate_css_file("page", path)

		if not page_file then
			error_messages.errors()["unable_to_create"]("page")
			return nil
		end

		page_file:write(page)
		page_file:close()
	end
end

-- TODO: Create functions to to simplify how svg files are created
M.generate_svg = function(svg_name, file_path)
	local config_values = config.get_config_values()

	if config_values == nil then
		error_messages.critical_errors()["no_config_file"]()
		return
	end

	local generated_svg_path

	generated_svg_path, svg_name = extract_path_name(svg_name, generated_svg_path)

	if not generated_svg_path or not svg_name then
		print(colors.red .. "ERROR: You need to provide a valid svg name!" .. colors.reset)
		os.exit(1)
	end

	local has_custom_extension = svg_name:match("%.[%w]+$")
	local full_name = has_custom_extension and svg_name or (svg_name .. "." .. config_values.extension)

	svg_name = svg_name:match("(.+)%..+") or svg_name

	if not file_exist(generated_svg_path .. full_name) then
		if not file_path then
			print(colors.yellow .. "You didn't provide a path to a svg file! Is this what you want?" .. colors.reset)
			local valid_options = { "y", "n" }
			local answer

			repeat
				print("Do you want to create a default SVG file? (Y/n)")
				io.write("--> ")
				answer = io.read()
				answer = answer:lower()

				if answer == "" then
					answer = "y"
				end

				if not validate_input(answer, valid_options) then
					print(colors.red .. "Invalid input. Please try again." .. colors.reset)
				end
			until validate_input(answer, valid_options)

			if answer == "y" then
				os.execute("mkdir -p " .. generated_svg_path)
				local svg_file = io.open(generated_svg_path .. full_name, "w")

				if not svg_file then
					error_messages.errors()["unable_to_create"]("file containing the svg")
					return nil
				end

				local svg = get_svg_template(svg_name, nil)

				svg_file:write(svg)
				svg_file:close()
			else
				print(colors.yellow .. "Operation canceled" .. colors.reset)
				print("You can try: lg --help for more information")
			end
		elseif file_path ~= nil and not file_exist(file_path) then
			print(colors.red .. "ERROR: File " .. file_path .. " does not exist!" .. colors.reset)
			local valid_options = { "y", "n" }
			local answer

			repeat
				print("Do you want to create a default SVG file? (Y/n)")
				io.write("--> ")
				answer = io.read()
				answer = answer:lower()

				if answer == "" then
					answer = "y"
				end

				if not validate_input(answer, valid_options) then
					print(colors.red .. "Invalid input. Please try again." .. colors.reset)
				end
			until validate_input(answer, valid_options)

			if answer == "y" then
				os.execute("mkdir -p " .. generated_svg_path)
				local svg_file = io.open(generated_svg_path .. full_name, "w")

				if not svg_file then
					error_messages.errors()["unable_to_create"]("file containing the svg")
					return nil
				end

				local svg = get_svg_template(svg_name, nil)

				svg_file:write(svg)
				svg_file:close()
			else
				print(colors.yellow .. "Operation canceled" .. colors.reset)
			end
		elseif file_path ~= nil and file_exist(file_path) then
			local svg_content = io.open(file_path):read("*a"):match("<svg.->(.-)</svg>")
			local svg

			svg = get_svg_template(svg_name, svg_content)

			os.execute("mkdir -p " .. generated_svg_path)
			local svg_file = io.open(generated_svg_path .. full_name, "w")

			if not svg_file then
				error_messages.errors()["unable_to_create"]("file containing the svg")
				return nil
			end

			svg_file:write(svg)
			svg_file:close()
		else
			local svg = get_svg_template(svg_name, nil)

			os.execute("mkdir -p " .. generated_svg_path)
			local svg_file = io.open(generated_svg_path .. full_name, "w")

			if not svg_file then
				error_messages.errors()["unable_to_create"]("file containing the svg")
				return nil
			end

			svg_file:write(svg)
			svg_file:close()
		end
	else
		print(colors.yellow .. "ALERT! File already exists" .. colors.reset)
		local valid_options = { "y", "n" }
		local answer

		repeat
			print("Do you want to overwrite it? (y/N)")
			io.write("--> ")
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
			if file_path ~= nil and not file_exist(file_path) then
				print(colors.red .. "ERROR: File " .. file_path .. " does not exist!" .. colors.reset)

				repeat
					print("Do you want to create a default SVG file? (Y/n)")
					io.write("--> ")
					answer = io.read()
					answer = answer:lower()

					if answer == "" then
						answer = "y"
					end

					if not validate_input(answer, valid_options) then
						print(colors.red .. "Invalid input. Please try again." .. colors.reset)
					end
				until validate_input(answer, valid_options)

				if answer == "y" then
					os.execute("mkdir -p " .. generated_svg_path)
					local svg_file = io.open(generated_svg_path .. full_name, "w")

					if not svg_file then
						error_messages.errors()["unable_to_create"]("file containing the svg")
						return nil
					end

					local svg = get_svg_template(svg_name, nil)

					svg_file:write(svg)
					svg_file:close()
				else
					print(colors.yellow .. "Operation canceled" .. colors.reset)
				end
			elseif file_path ~= nil and file_exist(file_path) then
				local svg_content = io.open(file_path):read("*a"):match("<svg.->(.-)</svg>")
				local svg = get_svg_template(svg_name, svg_content)

				os.execute("mkdir -p " .. generated_svg_path)
				local svg_file = io.open(generated_svg_path .. full_name, "w")

				if not svg_file then
					error_messages.errors()["unable_to_create"]("file containing the svg")
					return nil
				end

				svg_file:write(svg)
				svg_file:close()
			else
				local svg = get_svg_template(svg_name, nil)

				os.execute("mkdir -p " .. generated_svg_path)
				local svg_file = io.open(generated_svg_path .. full_name, "w")

				if not svg_file then
					error_messages.errors()["unable_to_create"]("file containing the svg")
					return nil
				end

				svg_file:write(svg)
				svg_file:close()
			end
		else
			print(colors.yellow .. "Operation canceled" .. colors.reset)
		end
	end
end

return M
