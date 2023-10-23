local delim = require("cells.delimiter")

local M = {}

-- Draws cell separators as virtual text using nvim's extmark functionality
function M.draw_separators()
    local buffer = 0
    local ns_id = vim.api.nvim_create_namespace("cells")
    local extmarks = vim.api.nvim_buf_get_extmarks(buffer, ns_id, 0, -1, {})

    -- For each separator: map line -> state := {id, delete},
    -- where the delete-flag indicates that the border should be deleted,
    -- this is initally set to true for all borders and later flipped if
    -- a cell delimiter still exists at the line.
    local separators = {}
    for _, ext_tuple in ipairs(extmarks) do
        local id, line = unpack(ext_tuple)
        separators[line] = { id = id, delete = true }
    end

    local opts = {
        virt_text = { { "", "Comment" } },
        virt_text_pos = "eol",
        strict = false,
    }

    -- Start from BOF and look for existing cell delimiters, the first
    -- time we call find_next_delim() we have to accept a match
    -- at the current line in case file starts with a cell delimiter.
    local pos_old = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local accept_curr = true
    while true do
        local pos_next = delim.find_next_delim({ move_cursor = false, accept_curr = accept_curr })
        if not pos_next then
            -- no more delimiters, delete old borders not marked for saving
            for _, state in pairs(separators) do
                if state.delete then
                    vim.api.nvim_buf_del_extmark(buffer, ns_id, state.id)
                end
            end
            vim.api.nvim_win_set_cursor(0, pos_old)
            return
        else -- delimiter found
            vim.api.nvim_win_set_cursor(0, pos_next)
            accept_curr = false
            local line = pos_next[1]
            if not separators[line] then -- draw new border
                opts.id = line
                local win_width = vim.api.nvim_win_get_width(0)
                local num_sep = win_width - vim.fn.col("$")
                opts.virt_text[1][1] = string.rep(require("cells.config").options.separator, num_sep)
                vim.api.nvim_buf_set_extmark(buffer, ns_id, line - 1, 0, opts)
            else -- save existing border
                separators[line].delete = false
            end
        end
    end
end

return M
