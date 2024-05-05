local M = {}

local version = require("version")

function M.search(query)
    local curl = require("plenary.curl")
    local resp = curl.get("https://azuresearch-usnc.nuget.org/query?q=" .. query, { timeout = 2000 })
    local json = vim.fn.json_decode(resp.body)

    if json then
        return json.data
    end
end

function M.get_latest_version(package_id)
    local package_data = M.search(package_id)[1]
    return package_data.version
end

function M.get_versions(package_id)
    local package_data = M.search(package_id)[1]
    local raw_versions = package_data.versions
    local versions = vim.tbl_map(
        function(v)
            return v.version
        end,
        raw_versions
    )

    return versions
end

function M.get_latest_of_type(package_id, type)
    local versions = M.get_versions(package_id)
    version.resolve_version(versions, M.get_latest_version(package_id), type)
end

return M

