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



	local parse_statement, parse_variable_declaration, parse_print_statement, parse_expression, parse_primary, parse_run_lua, parse_run_python
	local parse_block, parse_if, parse_while, parse_for



	parse_block = function(stop_tokens)
		local statements = {}

		while cursor <= #tokens do
			local t = peek().type

			for _, stop in ipairs(stop_tokens) do
				if t == stop then
					return statements
				end
			end
		end
	end

	parse_if = function()
		advance() -- consume 'if'
		local condition = parse_expression()
		match("KEYWORD_THEN")
		
		local then_body = parse_block({"KEYWORD_ELSEIF", "KEYWORD_ELSE", "DOT"})
		local elseif_branches = {}
		local else_body = nil

		while peek() and peek().type == "KEYWORD_ELSEIF" do
			advance() -- consume 'elseif'
			local cond = parse_expression()
			match("KEYWORD_THEN")
			local body = parse_block({"KEYWORD_ELSEIF", "KEYWORD_ELSE", "DOT"})
			table.insert(elseif_branches, { condition = cond, body = body })
		end

		if peek() and peek().type == "KEYWORD_ELSE" then
			advance() -- consume 'else'
			else_body = parse_block({"DOT"})
		end

		match("DOT") -- end block with .
		return {
			type = "IfStatement",
			condition = condition,
			then_body = then_body,
			elseif_branches = elseif_branches,
			else_body = else_body
		}
	end

	parse_while = function()
		advance() -- consume 'while'
		local condition = parse_expression()
		match("KEYWORD_DO")
		local body = parse_block({"DOT"})
		match("DOT")
		return { type = "WhileStatement", condition = condition, body = body }
	end

	parse_for = function()
		advance() -- consume 'for'
		local var_name = advance().value -- variable identifier
		match("EQUALS")
		local start_expr = parse_expression()
		
		-- Match comma (if you don't tokenise comma yet, advance or add COMMA token)
		if peek().value == "," then advance() end 
		
		local end_expr = parse_expression()
		match("KEYWORD_DO")
		local body = parse_block({"DOT"})
		match("DOT")
		return {
			type = "ForStatement",
			var_name = var_name,
			start_expr = start_expr,
			end_expr = end_expr,
			body = body
		}
	end



	parse_statement = function()
		if peek().type == "KEYWORD_VAR" then
			return parse_variable_declaration()
		elseif peek().type == "KEYWORD_PRINT" then
			return parse_print_statement()
		elseif peek().type == "KEYWORD_RUN_LUA" then
			return parse_run_lua()
		elseif peek().type == "KEYWORD_RUN_PYTHON" then
			return parse_run_python()
		elseif t == "KEYWORD_IF" then
			return parse_if()
		elseif t == "KEYWORD_WHILE" then
			return parse_while()
		elseif t == "KEYWORD_FOR" then
			return parse_for()
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

		if p.type == "NUMBER" or p.type == "STRING" then
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

	parse_run_lua = function()
		advance()

		local expr = parse_expression()

		return {type = "LuaCode", value = expr}
	end

	parse_run_python = function()
		advance()

		local expr = parse_expression()

		return {type = "PythonCode", value = expr}
	end





	local ast = {}
	while cursor <= #tokens do
	    table.insert(ast, parse_statement())
	end
	return ast
end

return parser