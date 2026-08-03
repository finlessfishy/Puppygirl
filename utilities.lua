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



return utilities