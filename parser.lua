


function parse(tokens)
	local cursor = 1

	local function peek()
		return tokens[cursor]
	end

	local function advance()
		cursor += 1
		return cursor - 1
	end

	local function match(expected_type)
		if expected_type == peek() then
			return advance()
		else
			print("SYNTAX ERROR (match function)")
		end
	end
end