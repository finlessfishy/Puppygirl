local interpreter = {}



function interpreter.run(ast)
	local environment = {}

	local function evaluate(node)
		if node.type == "Literal" then
			return node.value
		elseif node.type == "VariableAccess" then
			if environment[node.name] ~= nil then
				return environment[node.name]
			else
				error("Runtime Error: Undefined variable '" .. node.name .. "'")
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
		elseif node.type == "LuaCode" then
			local lua_str = evaluate(node.value)
			local dynamicFunction, errorMessage = load(lua_str)

			if dynamicFunction then
				dynamicFunction()
			else
				print(errorMessage)
			end
		elseif node.type == "PythonCode" then
			py_code = evaluate(node.value)

			local info = debug.getinfo(1, "S")
			local lua_dir = info.source:match("@?(.*[/\\])") or "./"
			local full_path = lua_dir .. "runcode.py"

			py_code = py_code:gsub('"', '\\"')

			os.execute('python3 ' .. full_path .. ' "' .. py_code .. '"')
		end
	end

	for _, statement in ipairs(ast) do
		evaluate(statement)
	end

	return environment
end



return interpreter