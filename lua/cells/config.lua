local M = {}

local defaults = {
    cell_delimiter = "%%",
    cell_separator = "─",
}

function M.configure(opts)
    opts = opts or {}
    M.options = vim.tbl_deep_extend("force", defaults, opts)
end

return M
