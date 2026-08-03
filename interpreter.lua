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
		end
	end

	for _, statement in ipairs(ast) do
        evaluate(statement)
    end

    return environment
end



return interpreter