local delim = require("cells.delimiter")

local M = {}

local function select_region(region)
    vim.api.nvim_win_set_cursor(0, { region.from.line, 0 })
    if not vim.fn.mode():find("V") then
        vim.cmd.normal("V")
    end
    vim.cmd.normal("o")
    vim.api.nvim_win_set_cursor(0, { region.to.line, 0 })
end

function M.cell(ai_type)
    local region = delim.get_cell_region(ai_type)
    select_region(region)
end

return M
