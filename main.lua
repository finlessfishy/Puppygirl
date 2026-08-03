local tokenizer = require("tokenizer")
local parser = require("parser")
local interpreter = require("interpreter")



local function run_code(code)
	local tokens = tokenizer.tokenize(code)
	local ast = parser.parse(tokens)
	local env = interpreter.run(ast)

	return env
end


--print("output: ", env["panda"]) -- Outputs: panda = 20



code = [[
	var panda = 16 + 4
	print panda
]]

run_code(code)