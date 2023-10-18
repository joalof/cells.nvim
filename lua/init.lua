local config = require("cells.config")

local M = {}

function M.setup(opts)
    config.configure(opts)
end

return M
