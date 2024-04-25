List = {}

---Groups a list by the result of a function
---Elements that return the same value will be grouped together
---@generic T Element of list
---@generic R Result type of grouping function
---@param list T[]
---@param fn fun(v: T): R
---@return { [R]: T[] }
function List.group_by(list, fn)
    local result = {}

    for _, v in ipairs(list) do
        local group = fn(v)

        if not result[group] then
            result[group] = {}
        end

        table.insert(result[group], v)
    end

    return result
end

---Returns list of distinct elements from a list
function List.distinct(list)
    local result = {}

    for _, v in ipairs(list) do
        if not vim.tbl_contains(result, v) then
            table.insert(result, v)
        end
    end

    return result
end

return List
