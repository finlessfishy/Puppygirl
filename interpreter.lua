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
        end
    end
    return found
end

interpreter.collect_python_code = collect_python_code



function interpreter.run(ast)
	local environment = {}

	local function evaluate(node)
		if node.type == "Literal" then
			return node.value
		elseif node.type == "VariableAccess" then
			if environment[node.name] ~= nil then
				return environment[node.name]
			else
				error("Oh no, an error!!! Your variable isn't defined! '" .. node.name .. "'")
			end
		elseif node.type == "BinaryExpr" then
			local leftV = evaluate(node.left)
			local rightV = evaluate(node.right)

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
			local v = evaluate(node.value)
			environment[node.name] = v
		elseif node.type == "PrintStatement" then
			local value = evaluate(node.value)

			print(value)
		elseif node.type == "PythonCode" then
		    local py_code = evaluate(node.value)

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
			if evaluate(node.condition) then
				for _, stmt in ipairs(node.then_body) do evaluate(stmt) end
			else
				local handled = false
				for _, branch in ipairs(node.elseif_branches) do
					if evaluate(branch.condition) then
						for _, stmt in ipairs(branch.body) do evaluate(stmt) end
						handled = true
						break
					end
				end
				if not handled and node.else_body then
					for _, stmt in ipairs(node.else_body) do evaluate(stmt) end
				end
			end

		elseif node.type == "WhileStatement" then
			while evaluate(node.condition) do
				for _, stmt in ipairs(node.body) do evaluate(stmt) end
			end

		elseif node.type == "ForStatement" then
			local start_val = evaluate(node.start_expr)
			local end_val = evaluate(node.end_expr)
			for i = start_val, end_val do
				environment[node.var_name] = i
				for _, stmt in ipairs(node.body) do evaluate(stmt) end
			end
		elseif node.type == "InputExpr" then
		    if node.prompt then
		        io.write(tostring(evaluate(node.prompt)))
		    end
		    return io.read("*l")
		else
    		return { type = "ExpressionStatement", value = parse_expression() }
		end
	end

	for _, statement in ipairs(ast) do
		evaluate(statement)
	end

	return environment
end



return interpreter