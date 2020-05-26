local util = {}

function util.sorted_pairs(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
    local k = 0
    local iter = function()
        k = k + 1
        local key = keys[k]
        if not key then
            return nil
        end
        return key, t[key]
    end
    return iter
end

return util
