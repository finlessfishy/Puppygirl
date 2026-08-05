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

	-- match()
	local function match(expected_type)
	    if peek() and expected_type == peek().type then
	        return advance()
	    else
	        error("I got confused around token" .. cursor .. ".. I expected " .. expected_type .. ", but I got " ..
	              (peek() and peek().type or "EOF") .. "...")
	    end
	end



	local parse_statement, parse_variable_declaration, parse_print_statement, parse_expression, parse_primary, parse_run_python, parse_function_declaration, parse_return_statement
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

			table.insert(statements, parse_statement())
		end

		return statements
	end

	parse_if = function()
		advance() -- consume 'if'
		local condition = parse_expression()
		match("KEYWORD_THEN")
		
		local then_body = parse_block({"KEYWORD_ELSEIF", "KEYWORD_ELSE", "KEYWORD_GOODGIRL"})
		local elseif_branches = {}
		local else_body = nil

		while peek() and peek().type == "KEYWORD_ELSEIF" do
			advance() -- consume 'elseif'
			local cond = parse_expression()
			match("KEYWORD_THEN")
			local body = parse_block({"KEYWORD_ELSEIF", "KEYWORD_ELSE", "KEYWORD_GOODGIRL"})
			table.insert(elseif_branches, { condition = cond, body = body })
		end

		if peek() and peek().type == "KEYWORD_ELSE" then
			advance() -- consume 'else'
			else_body = parse_block({"KEYWORD_GOODGIRL"})
		end

		match("KEYWORD_GOODGIRL") -- end block with goodgirl
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
		local body = parse_block({"KEYWORD_GOODGIRL"})
		match("KEYWORD_GOODGIRL")
		return { type = "WhileStatement", condition = condition, body = body }
	end

	parse_for = function()
		advance() -- consume 'for'
		local var_name = advance().value -- variable identifier
		match("EQUALS")
		local start_expr = parse_expression()
		
		match("COMMA")
		
		local end_expr = parse_expression()
		match("KEYWORD_DO")
		local body = parse_block({"KEYWORD_GOODGIRL"})
		match("KEYWORD_GOODGIRL")
		return {
			type = "ForStatement",
			var_name = var_name,
			start_expr = start_expr,
			end_expr = end_expr,
			body = body
		}
	end



	-- parse_statement(), add an else branch
	-- parser.lua around line 118
	parse_statement = function()
	    local t = peek().type
	    if t == "KEYWORD_VAR" then
	        return parse_variable_declaration()
	    elseif t == "KEYWORD_PRINT" then
	        return parse_print_statement()
	    elseif t == "KEYWORD_RUN_PYTHON" then
	        return parse_run_python()
	    elseif t == "KEYWORD_IF" then
	        return parse_if()
	    elseif t == "KEYWORD_WHILE" then
	        return parse_while()
	    elseif t == "KEYWORD_FOR" then
	        return parse_for()
	    elseif t == "KEYWORD_TRICK" then
	        return parse_function_declaration()
	    elseif t == "KEYWORD_FETCH" then
	        return parse_return_statement()
	    elseif t == "IDENTIFIER" then
	        -- Look ahead at the next token to check what kind of statement this is!
	        local name_token = advance()
	        
	        -- If it's followed by '(', it's a standalone function call (e.g. play_sound())
	        if peek() and peek().type == "LPAREN" then
	            advance() -- consume '('
	            local args = {}
	            if peek() and peek().type ~= "RPAREN" then
	                table.insert(args, parse_expression())
	                while peek() and peek().type == "COMMA" do
	                    advance()
	                    table.insert(args, parse_expression())
	                end
	            end
	            match("RPAREN")
	            return { type = "FunctionCall", name = name_token.value, args = args }
	            
	        -- If it's followed by '=', it's a variable re-assignment (e.g. msg = msg + "!")
	        elseif peek() and peek().type == "EQUALS" then
	            advance() -- consume '='
	            local expr = parse_expression()
	            return { type = "AssignmentStatement", name = name_token.value, value = expr }
	        else
	            error("Oops! Found identifier '" .. name_token.value .. "' but expected '(' or '='!")
	        end
	    else
	        error("Oops! I found an unexpected token!! '" .. tostring(peek().value) ..
	              "' (" .. t .. "), and I think it was at token " .. cursor .. "!")
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
			print("Oh noo, I got a syntax error!!!!")
		end
	end

	parse_expression = function()
	    local expr = parse_primary()

	    while peek() and (peek().value == "+" or peek().value == "-" or peek().value == "==" or peek().value == "*") do
	        local op = advance()
	        local right = parse_primary()
	        expr = {
	            type = "BinaryExpr",
	            operator = op.value,
	            left = expr,
	            right = right
	        }
    	end

    	return expr
	end

	parse_primary = function()
		p = peek()

		if p.type == "NUMBER" or p.type == "STRING" then
			advance()
			return {type = "Literal", value = p.value}
		elseif p.type == "KEYWORD_TRUE" then
			advance()
			return {type = "Literal", value = true}
		elseif p.type == "KEYWORD_FALSE" then
			advance()
			return {type = "Literal", value = false}
		-- parser.lua (inside parse_primary)
		elseif p.type == "IDENTIFIER" then
		    local id_token = advance() -- Save the identifier token right here!
		    
		    if peek() and peek().type == "LPAREN" then
		        advance() -- consume '('
		        local args = {}
		        if peek() and peek().type ~= "RPAREN" then
		            table.insert(args, parse_expression())
		            while peek() and peek().type == "COMMA" do
		                advance()
		                table.insert(args, parse_expression())
		            end
		        end
		        match("RPAREN")
		        -- Use id_token.value instead of p.value!
		        return { type = "FunctionCall", name = id_token.value, args = args }
		    end
    return { type = "VariableAccess", name = id_token.value }
		elseif p.type == "KEYWORD_LISTEN" then
		    advance()
		    local prompt = nil
		    local nxt = peek()
		    if nxt and (nxt.type == "STRING" or nxt.type == "NUMBER" or nxt.type == "IDENTIFIER") then
		        prompt = parse_expression()
		    end
    		return { type = "InputExpr", prompt = prompt }
		else
			print("Oopsies, a syntax error!")
		end
	end

	parse_print_statement = function()
		advance()

		local expr = parse_expression()

		return {type = "PrintStatement", value = expr}
	end

	parse_run_python = function()
		advance()

		local expr = parse_expression()

		return {type = "PythonCode", value = expr}
	end

	parse_function_declaration = function()
		advance() -- consume 'trick'
		local name_token = match("IDENTIFIER")
		match("LPAREN")

		local params = {}
		if peek() and peek().type ~= "RPAREN" then
			table.insert(params, match("IDENTIFIER").value)
			while peek() and peek().type == "COMMA" do
				advance()
				table.insert(params, match("IDENTIFIER").value)
			end
		end
		match("RPAREN")
		match("KEYWORD_DO")

		local body = parse_block({"KEYWORD_GOODGIRL"})
		match("KEYWORD_GOODGIRL")

		return { type = "FunctionDeclaration", name = name_token.value, params = params, body = body }
	end

	parse_return_statement = function()
		advance() -- consume 'fetch'
		local expr = parse_expression()
		return { type = "ReturnStatement", value = expr }
	end



	local ast = {}

	while cursor <= #tokens do
	    if peek().type == "KEYWORD_GOODGIRL" then
	        if cursor == #tokens then
	            advance()
	            return ast
	        end
	    end
	    table.insert(ast, parse_statement())
	end
	
	error("Oh no! Your script didn't end with a goodgirl! Every good script deserves praise after working so hard!!")
end

return parser