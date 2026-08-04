local KEYWORDS = {
	["make"] = "KEYWORD_VAR", -- var
	["woof"] = "KEYWORD_PRINT",
	["runpython"] = "KEYWORD_RUN_PYTHON",
	["if"]		= "KEYWORD_IF",
	["then"]	  = "KEYWORD_THEN",
	["elseif"]	= "KEYWORD_ELSEIF",
	["else"]	  = "KEYWORD_ELSE",
	["again"]	 = "KEYWORD_WHILE",
	["do"]		= "KEYWORD_DO",
	["everytime"]	   = "KEYWORD_FOR",
	["listen"] = "KEYWORD_LISTEN",
	["goodgirl"] = "KEYWORD_GOODGIRL",
	["yep"] = "KEYWORD_TRUE",
	["nope"] = "KEYWORD_FALSE",
}

local tokenizer = {}

function tokenizer.tokenize(str)
	local main_table = {}
	local cursor = 1
	local len = #str

	while cursor <= len do
		local c = str:sub(cursor, cursor)

		-- 1. Skip whitespace
		if c:match("%s") then
			cursor = cursor + 1

		-- Inside tokenizer.tokenize loop, before single-character operators:
		elseif c == '"' then
			cursor = cursor + 1 -- Skip opening quote
			local start = cursor

			-- Scan until closing quote or end of input
			while cursor <= len and str:sub(cursor, cursor) ~= '"' do
				cursor = cursor + 1
			end

			if cursor > len then
				error("Oh no, I got a Lexing Error: Unterminated string literal. Whatever that means!!")
			end

			local text = str:sub(start, cursor - 1)
			cursor = cursor + 1 -- Skip closing quote

			table.insert(main_table, { type = "STRING", value = text })

		-- 2. Numbers
		elseif c:match("%d") then
			local start = cursor
			while cursor <= len and str:sub(cursor, cursor):match("%d") do
				cursor = cursor + 1
			end
			local num_str = str:sub(start, cursor - 1)
			table.insert(main_table, { type = "NUMBER", value = tonumber(num_str) })

		-- 3. Identifiers & Keywords
		elseif c:match("[%a_]") then
			local start = cursor
			while cursor <= len and str:sub(cursor, cursor):match("[%w_]") do
				cursor = cursor + 1
			end
			local word = str:sub(start, cursor - 1)
			table.insert(main_table, { type = KEYWORDS[word] or "IDENTIFIER", value = word })

		-- 4. Check for == vs =
		elseif c == "=" then
			-- Peek at the next character
			if cursor + 1 <= len and str:sub(cursor + 1, cursor + 1) == "=" then
				table.insert(main_table, { type = "EQUAL_EQUAL", value = "==" })
				cursor = cursor + 2 -- Advance past BOTH '=' characters
			else
				table.insert(main_table, { type = "EQUALS", value = "=" })
				cursor = cursor + 1
			end

		-- 5. Single-character Operators
		elseif c == "+" then
			table.insert(main_table, { type = "PLUS", value = "+" })
			cursor = cursor + 1
		elseif c == "-" then
			table.insert(main_table, { type = "MINUS", value = "-" })
			cursor = cursor + 1
		elseif c == "*" then
			table.insert(main_table, { type = "STAR", value = "*" })
			cursor = cursor + 1
		elseif c == "*" then
			table.insert(main_table, { type = "STAR", value = "*" })
			cursor = cursor + 1
		elseif c == "," then
			table.insert(main_table, { type = "COMMA", value = "," })
			cursor = cursor + 1
		else
			error("I found an unexpected character!! Here it is: " .. c)
		end
	end

	return main_table
end

return tokenizer