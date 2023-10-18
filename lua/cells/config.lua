local M = {}

local defaults = {
    cell_delimiter = "%%",
    cell_separator = "─",
}

M.options = {}

function M.setup(options)
    M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
