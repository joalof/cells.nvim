local delim = require("cells.delimiter")

local M = {}

local function select_lines(start, stop)
    vim.api.nvim_win_set_cursor(0, { start, 0 })
    if not vim.fn.mode():find("V") then
        vim.cmd.normal("V")
    end
    vim.cmd.normal("o")
    vim.api.nvim_win_set_cursor(0, { stop, 0 })
end

function M.select_cell(ai_type)
    local extent = delim.get_cell_extent(ai_type)
    select_lines(extent.start, extent.stop)
end

return M
