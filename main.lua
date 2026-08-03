local version = "0.6.8"

local tokenizer = require("tokenizer")
local parser = require("parser")
local interpreter = require("interpreter")



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



local code = [[
	var panda = 16 + 4
	print panda

	var txt = "texting fox rn"
	print txt
	print "ok"
	print "ok" + 3
]]

local code2 = [[
	var luacode = "print('hi')"
	runlua luacode
]]


run_code(code2)