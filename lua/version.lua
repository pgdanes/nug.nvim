M = {}

function M.sort_versions(versions)
    table.sort(versions, function(a, b) return vim.version.cmp(a,b) > 0 end)
end

function M.sort_version(v1, v2)
    return vim.version.cmp(v1, v2) > 0
end

function M.resolve_version(version_strings, current_version, requested_upgrade)
    local versions = vim.tbl_map(vim.version.parse, version_strings)
    table.sort(versions, M.sort_version)

    local success, current = pcall(vim.version.parse, current_version)
    if not success or current == nil then
        vim.notify("Invalid version: " .. current_version, vim.log.levels.ERROR)
        return
    end

    if requested_upgrade == "major" then
        -- wanting the latest major is equivalent to the latest version
        return versions[1]
    elseif requested_upgrade == "minor" then
        local filtered = M.get_versions_of_same_type(versions, "major", current.major)
        return filtered[1]
    elseif requested_upgrade == "patch" then
        local filtered = M.get_versions_of_same_type(versions, "minor", current.minor)
        return filtered[1]
    end

    return nil
end

function M.get_versions_of_same_type(versions, type, current_type_value)
    local filtered = vim.tbl_filter(
        function (v)
            if type == "major" then
                return v.major == current_type_value
            elseif type == "minor" then
                return v.minor == current_type_value
            elseif type == "patch" then
                return v.patch == current_type_value
            end
            return false
        end,
        versions)
    return filtered
end

return M;

