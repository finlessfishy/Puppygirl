local parser = {}



function parser.parse(tokens)
	local cursor = 1

	local function peek()
		return tokens[cursor]
	end

	local function advance()
		cursor = cursor + 1
		return tokens[cursor-1]
	end

	local function match(expected_type)
		if expected_type == peek().type then
			return advance()
		else
			print("SYNTAX ERROR (match function)")
		end
	end



	local parse_statement, parse_variable_declaration, parse_print_statement, parse_expression, parse_primary



	parse_statement = function()
		if peek().type == "KEYWORD_VAR" then
			return parse_variable_declaration()
		elseif peek().type == "KEYWORD_PRINT" then
			return parse_print_statement()
		end
	end

	parse_variable_declaration = function()
		advance()
		if peek().type == "IDENTIFIER" then
			identifier = peek()

			advance()
			advance()

			expr = parse_expression()

			return {type = "VarDeclaration", name = identifier.value, value = expr}
		else
			print("SYNTAX ERROR (parse_variable_declaration function)")
		end
	end

	parse_expression = function()
		primaryL = parse_primary()

		local p = peek()
		if not p or (p.value ~= "+" and p.value ~= "-" and p.value ~= "==" and p.value ~= "*") then
		    return primaryL
		else
			op = peek()

			advance()

			primaryR = parse_primary()

			return {type = "BinaryExpr", operator = op.value, left = primaryL, right = primaryR}
		end
	end

	parse_primary = function()
		p = peek()

		if p.type == "NUMBER" then
			advance()
			return {type = "Literal", value = p.value}
		elseif p.type == "IDENTIFIER" then
			advance()
			return { type = "VariableAccess", name = p.value }
		else
			print("SYNTAX ERROR (parse_primary function)")
		end
	end

	parse_print_statement = function()
		advance()

		local expr = parse_expression()

		return {type = "PrintStatement", value = expr}
	end



	local ast = {}
	while cursor <= #tokens do
	    table.insert(ast, parse_statement())
	end
	return ast
end

return parser