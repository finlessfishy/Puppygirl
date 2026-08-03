local version = "0.7.0"

local tokenizer = require("tokenizer")
local parser = require("parser")
local interpreter = require("interpreter")

local utilities = require("utilities")



local function run_code(code, intro)
	if intro == nil then
		intro = true
	end

	if intro == true then
		print("Running puppygirl " .. version)
	end



	local tokens = tokenizer.tokenize(code)
	local ast = parser.parse(tokens)
	local env = interpreter.run(ast)

	return env
end



io.write(".pg script file path: ")
path = io.read()
local file, e = io.open(path, "r")



if not file then
    print("Error opening file: " .. e)
    os.exit()
elseif utilities.endswith(path, ".pg") == false then
	print("Error, the file you chose isn't a .pg puppygirl script file.")
	os.exit()
end



local code = file:read("*a")
file:close()



run_code(code)