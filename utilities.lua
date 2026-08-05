local utilities = {}



function utilities.tablelen(t)
    local c = 0
    for _, _ in pairs(t) do
        c = c + 1
    end
    return c
end



function utilities.startswith(str, start)
    return str:sub(1, #start) == start
end

function utilities.endswith(str, ending)
    if type(str) ~= "string" or type(ending) ~= "string" then
        return false
    end
    return ending == "" or str:sub(-#ending) == ending
end



function clear()
    if package.config:sub(1,1) == '\\' then
        os.execute("cls")
    else
        os.execute("clear")
    end
end



function is_windows()
    local os_env = os.getenv("OS") or ""
    local is_it_windows = os_env:match("^Windows") ~= nil

    if is_it_windows then
        return true
    else
        return false
    end
end




return utilities