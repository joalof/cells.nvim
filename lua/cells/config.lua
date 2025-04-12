local M = {}

local DEFAULTS = {
    delimiter = "%%",
    separator = "─",
}

M.options = {}

function M.configure(opts)
    opts = opts or {}
    M.options = vim.tbl_deep_extend("force", DEFAULTS, opts)
end

return M
