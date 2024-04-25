local M = {}

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

return M

