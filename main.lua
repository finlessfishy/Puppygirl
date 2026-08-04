local version = "0.9.8"

local tokenizer = require("tokenizer")
local parser = require("parser")
local interpreter = require("interpreter")

local utilities = require("utilities")

local ascii_library = require("ascii_library")



local function run_code(code, intro)
	if intro == nil then
		intro = true
	end

	if intro == true then
		print("Running puppygirl " .. version)
	end

	local tokens = tokenizer.tokenize(code)
	local ast = parser.parse(tokens)

	-- Scan the whole script for Python code BEFORE running anything
	local python_snippets = interpreter.collect_python_code(ast)

	if #python_snippets > 0 then
		local combined = table.concat(python_snippets, "\n")
		local tmp_name = os.tmpname()
		local tmp_file = io.open(tmp_name, "w")
		tmp_file:write(combined)
		tmp_file:close()

		local info = debug.getinfo(1, "S")
		local lua_dir = info.source:match("@?(.*[/\\])") or "./"
		local runcode_path = lua_dir .. "runcode.py"

		local handle = io.popen('python3 -u "' .. runcode_path .. '" scan "' .. tmp_name .. '"')
		local warnings = {}
		for line in handle:lines() do
			table.insert(warnings, line)
		end
		handle:close()
		os.remove(tmp_name)

		if #warnings > 0 then
			print("\nPuppygirl warning: This script contains Python code that might try to do these things!!")
			for _, w in ipairs(warnings) do
				print("    - " .. w)
			end
			io.write("\nPress enter to continue, but only if you trust wherever you got this game from!!\nPress CTRL+C to quit.\n")
			io.read()
		end
	end

	local env = interpreter.run(ast)

	return env
end



io.write("Enter your .pg script file path! ")
path = io.read()
local file, e = io.open(path, "r")



if not file then
    print("I got an error opening your file! Here's the error: " .. e)
    os.exit()
elseif utilities.endswith(path, ".pg") == false then
	print("I got an error, the file you chose isn't a .pg puppygirl script file!!")
	os.exit()
end



local code = file:read("*a")
file:close()

print(ascii_library.pg)

local ok, result = pcall(run_code, code)
if not ok then
    print("Oh no, I got an error running your script! Here: " .. tostring(result))
end