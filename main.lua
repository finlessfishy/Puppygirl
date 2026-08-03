local version = "0.6.1"

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


--print("output: ", env["panda"]) -- Outputs: panda = 20



local code = [[
	var panda = 16 + 4
	print panda

	var txt = "texting fox rn"
	print txt
	print "ok"
]]

run_code(code)