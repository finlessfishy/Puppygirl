local KEYWORDS = {
	["var"] = "KEYWORD_VAR"
	["print"] = "KEYWORD_PRINT"
}


function tokenize(string)
	local tokens = {}
	local main_table = {}

    for t in str:gmatch("%d+|%a+|%p+|%S") do
        table.insert(tokens, t)
    end

    for i in tokens do
    	if tonumber(i) then -- if it's a number
    		table.insert(main_table, {type = "NUMBER", value = i})
    	elseif i == "+" then
    		table.insert(main_table, {type = "PLUS", value = "+"})
    	elseif i == "-" then
    		table.insert(main_table, {type = "MINUS", value = "-"})
    	elseif i == "*" then
    		table.insert(main_table, {type = "STAR", value = "*"})
    	elseif i == "=" then
    		table.insert(main_table, {type = "EQUALS", value = "+"})
    	else
    		table.insert(main_table, {type = KEYWORDS[i] or "IDENTIFIER", value = i})
    	end
    end


    return main_table
end