local M = {}

local defaults = {
    delimiter = "%%",
    separator = "─",
}

M.options = defaults

function M.configure(opts)
    opts = opts or {}
    M.options = vim.tbl_deep_extend("force", defaults, opts)
end

return M
