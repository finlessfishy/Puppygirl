local tokenizer = require("tokenizer")
local parser = require("parser")
local interpreter = require("interpreter")

local code = "var panda = 16 + 4"

local tokens = tokenizer.tokenize(code)
local ast = parser.parse(tokens)
local env = interpreter.run(ast)

print("output: ", env["panda"]) -- Outputs: panda = 20 !