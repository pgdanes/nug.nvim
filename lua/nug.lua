M = {}

-- TODO: Update package to latest Major/minor/patch/pre-release
-- TODO: Pull from local indexes rather than just global nuget
-- TODO: Completion for current projects, e.g. :NugUpdate <completion for references in projects>
local List = require("list")

---@class PackageRef : { project: string, package: string, version: string }

---@return PackageRef[]
local function package_to_str(package)
    return package.package .. ", v:" .. package.version
end

-- pulled from mason
local function calc_size(size, viewport)
    if size <= 1 then
        return math.ceil(size * viewport)
    end
    return math.min(size, viewport)
end

-- pulled from mason
local function create_popup_window_opts()
    local lines = vim.o.lines - vim.o.cmdheight
    local columns = vim.o.columns
    local height = calc_size(20, lines)
    local width = calc_size(80, columns)
    local row = math.floor((lines - height) / 2)
    local col = math.floor((columns - width) / 2)
    local popup_layout = {
        height = height,
        width = width,
        row = row,
        col = col,
        relative = "editor",
        style = "minimal",
        zindex = 45,
    }

    return popup_layout
end

function M.open_win()
    M.buf = vim.api.nvim_create_buf(false, true)
    M.win = vim.api.nvim_open_win(
        M.buf,
        true,
        create_popup_window_opts()
    )

    return M.buf
end

---@return boolean
function M.is_dotnet_installed()
    local path = vim.fn.system("which dotnet")
    return path ~= ""
end

-- It's quicker to do this than 'dotnet list package'
---@return PackageRef[]
function M.get_packages()
    local raw_refs = vim.fn
        .systemlist("grep --include=\"*.csproj\" -rnw . -e 'PackageReference'")

    local references = {}

    -- Example
    -- ./test-project.csproj:12:    <PackageReference Include="Newtonsoft.Json" Version="13.0.3" 
    for _, ref in ipairs(raw_refs) do
        local project = string.match(ref, "/(.*).csproj")
        local package = string.match(ref, "PackageReference Include=\"(.-)\"")
        local version = string.match(ref, "Version=\"(.-)\"")
        table.insert(references, { project = project, package = package, version = version })
    end

    return references
end

---Lists all project references in the current directory and nested directories.
---Internally this is just grepping through the csproj files, so resolved packages
---may differ from whats listed.
---@return nil
function M.list_package()
    local references = M.get_packages()
    if #references == 0 then
        vim.print("No packages found, are you in a dotnet project?")
        return
    end

    local projects = vim.tbl_map(function(r) return r.project end, references)
    projects = List.distinct(projects)

    local packages_by_project = List.group_by(
        references,
        function(ref) return ref.project end
    )

    local lines = {""}
    local package_name_lines = {}
    for _, project in ipairs(projects)  do
        table.insert(package_name_lines, #lines)
        table.insert(lines, project)
        local packages = packages_by_project[project]
        local project_lines = vim.tbl_map(package_to_str, packages)
        for _, line in ipairs(project_lines) do
            table.insert(lines, line)
        end

        table.insert(lines, "")
    end

    lines = vim.tbl_map(function(l) return "   " .. l end, lines)
    local win_buf_num = M.open_win()

    vim.api.nvim_buf_set_lines(win_buf_num, 0, -1, false, lines)
    for _, line in ipairs(package_name_lines) do
        vim.api.nvim_buf_add_highlight(win_buf_num, -1, "Function", line, 0, -1)
    end
end

function M.dotnet_list_packages()
    local lines = vim.fn.systemlist("dotnet list package")
    local win_buf_num = M.open_win()
    vim.api.nvim_buf_set_lines(win_buf_num, 0, -1, false, lines)
end

-- https://azuresearch-usnc.nuget.org/query?q=restsharp 
function M.search_nuget_feed(query)
    local results = require("nuget").search(query)
    vim.print(results)
end

vim.api.nvim_create_user_command(
    'NugPackages',
    M.list_package, {
        desc = "Show all nuget package references in any csproj in the current directory.",
        nargs = 0
    }
)

vim.api.nvim_create_user_command(
    'NugSearch',
    function(opts)
        M.search_nuget_feed(opts.args)
    end,
    {
        desc = "Search for nuget packages",
        nargs = 1
    }
)

vim.api.nvim_create_user_command(
    'NugLatest',
    function(opts)
        vim.print(require("nuget").get_latest_version(opts.args))
    end,
    {
        desc = "Get latest version of a nuget package.",
        nargs = 1
    }
)

return M
