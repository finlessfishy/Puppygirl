local tokenizer = require("tokenizer")
local parser = require("parser")

local result = tokenizer.tokenize("var panda = 16")

for _, token in ipairs(result) do
    print(token.type, token.value)
end