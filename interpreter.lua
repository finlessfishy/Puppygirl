local interpreter = {}



local function collect_python_code(ast, found)
    found = found or {}
    for _, node in ipairs(ast) do
        if node.type == "PythonCode" then
            if node.value.type == "Literal" then
                table.insert(found, tostring(node.value.value))
            end
        elseif node.type == "IfStatement" then
            collect_python_code(node.then_body, found)
            for _, branch in ipairs(node.elseif_branches) do
                collect_python_code(branch.body, found)
            end
            if node.else_body then
                collect_python_code(node.else_body, found)
            end
        elseif node.type == "WhileStatement" then
            collect_python_code(node.body, found)
        elseif node.type == "ForStatement" then
            collect_python_code(node.body, found)
        elseif node.type == "FunctionDeclaration" then
            collect_python_code(node.body, found)
        end
    end
    return found
end

interpreter.collect_python_code = collect_python_code



function interpreter.run(ast)
	local global_env = {}
	local functions = {}

	local evaluate, evaluate_block

	-- Runs a list of statements under `env`. If a `fetch` is hit (directly
	-- or inside a nested if/while/for), returns { __isReturn = true, value = ... }
	-- so callers can stop executing further statements/iterations.
	-- Returns nil if the block finished normally with no return.
	evaluate_block = function(body, env)
		for _, stmt in ipairs(body) do
			local result = evaluate(stmt, env)
			if type(result) == "table" and result.__isReturn then
				return result
			end
		end
		return nil
	end

	evaluate = function(node, env)
		env = env or global_env

		if node.type == "Literal" then
			return node.value
		elseif node.type == "VariableAccess" then
			if env[node.name] ~= nil then
				return env[node.name]
			elseif global_env[node.name] ~= nil then
				return global_env[node.name]
			else
				error("Oh no, an error!!! Your variable isn't defined! '" .. node.name .. "'")
			end
		elseif node.type == "BinaryExpr" then
			local leftV = evaluate(node.left, env)
			local rightV = evaluate(node.right, env)

			if node.operator == "+" then
				if type(leftV) == "string" or type(rightV) == "string" then
					return tostring(leftV) .. tostring(rightV)
				end
				return leftV + rightV
			elseif node.operator == "-" then
				return leftV - rightV
			elseif node.operator == "*" then
				return leftV * rightV
			elseif node.operator == "==" then
				return leftV == rightV
			end
		elseif node.type == "VarDeclaration" then
			local v = evaluate(node.value, env)
			env[node.name] = v
		elseif node.type == "PrintStatement" then
			local value = evaluate(node.value, env)
			print(value)
		elseif node.type == "PythonCode" then
		    local py_code = evaluate(node.value, env)

		    local info = debug.getinfo(1, "S")
		    local lua_dir = info.source:match("@?(.*[/\\])") or "./"
		    local full_path = lua_dir .. "runcode.py"

		    local tmp_name = os.tmpname()
		    local tmp_file = io.open(tmp_name, "w")
		    tmp_file:write(py_code)
		    tmp_file:close()

		    local handle = io.popen('python3 -u "' .. full_path .. '" run "' .. tmp_name .. '"')
		    for line in handle:lines() do
		        print(line)
		    end
		    handle:close()
		    os.remove(tmp_name)
		elseif node.type == "IfStatement" then
			if evaluate(node.condition, env) then
				return evaluate_block(node.then_body, env)
			else
				for _, branch in ipairs(node.elseif_branches) do
					if evaluate(branch.condition, env) then
						return evaluate_block(branch.body, env)
					end
				end
				if node.else_body then
					return evaluate_block(node.else_body, env)
				end
			end
		elseif node.type == "WhileStatement" then
			while evaluate(node.condition, env) do
				local result = evaluate_block(node.body, env)
				if result then return result end
			end
		elseif node.type == "ForStatement" then
			local start_val = evaluate(node.start_expr, env)
			local end_val = evaluate(node.end_expr, env)
			for i = start_val, end_val do
				env[node.var_name] = i
				local result = evaluate_block(node.body, env)
				if result then return result end
			end
		elseif node.type == "InputExpr" then
		    if node.prompt then
		        io.write(tostring(evaluate(node.prompt, env)))
		    end
		    return io.read("*l")
		elseif node.type == "FunctionDeclaration" then
			functions[node.name] = { params = node.params, body = node.body }
		elseif node.type == "FunctionCall" then
			local func = functions[node.name]
			if not func then
				error("Oh no! I don't know any trick called '" .. node.name .. "'!")
			end
			if #node.args ~= #func.params then
				error("Oh no! '" .. node.name .. "' expects " .. #func.params ..
					" argument(s), but got " .. #node.args .. "!")
			end

			local call_env = {}
			for i, pname in ipairs(func.params) do
				call_env[pname] = evaluate(node.args[i], env)
			end

			local result = evaluate_block(func.body, call_env)
			if result and result.__isReturn then
				return result.value
			end
			return nil
		elseif node.type == "ReturnStatement" then
			return { __isReturn = true, value = evaluate(node.value, env) }
		end
	end

	for _, statement in ipairs(ast) do
		evaluate(statement, global_env)
	end

	return global_env
end



return interpreter