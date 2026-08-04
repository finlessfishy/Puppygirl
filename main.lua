local version = "0.9.4"

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

	local has_lua = false
	local has_python = false

	for _, token in ipairs(tokens) do
	    if token.type == "KEYWORD_RUN_LUA" then
	        has_lua = true
	    elseif token.type == "KEYWORD_RUN_PYTHON" then
	        has_python = true
	    end
	end

	if has_lua or has_python then
		print()
	    if has_lua then
	    	print("\nWait!! There is Lua code execution in this game, so it might do dangerous things to your computer if the developer has bad intentions!")
	    	io.write("\nPress enter to continue, but only if you trust the developer!!!\n")
	    	io.read()
	    end
	    if has_python then
	    	print("\nWait!! There is Python code execution in this game, so it might do dangerous things to your computer if the developer has bad intentions!")
	    	io.write("\nPress enter to continue, but only if you trust the developer!!!\n")
	    	io.read()
	    end
	end

	local ast = parser.parse(tokens)
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