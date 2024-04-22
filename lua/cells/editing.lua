local delim = require("cells.delimiter")
local config = require('cells.config')

local M = {}

-- Moves the cursor to the first line of the prev cell.
-- Only moves the cursor if there is a cell above.
function M.cursor_to_prev_cell()
    -- first backward search: accept match at curr line after this
    -- we are guaranteed to be at the delim of the curr cell
    local pos_new = delim.find_prev_delim({ accept_curr = true })
    if pos_new then
        -- if file started with a delimiter: return early and dont move
        if pos_new[1] == 1 then
            return false
        end
        -- at least one cell above, move cursor
        vim.api.nvim_win_set_cursor(0, pos_new)

        -- second backward search: takes us to the delim of the prev cell
        pos_new = delim.find_prev_delim({ accept_curr = false })
        if pos_new then
            pos_new[1] = pos_new[1] + 1
            vim.api.nvim_win_set_cursor(0, pos_new)
        else  -- we hit BOF
            vim.api.nvim_win_set_cursor(0, {1, 0})
        end
        return true
    end
    return false
end

-- Moves the cursor to the first line of the next cell.
-- Only moves the cursor if there is a cell below.
function M.cursor_to_next_cell()
    local pos_new = delim.find_next_delim({ accept_curr = false })
    if pos_new then
        -- file ends in delimiter
        if pos_new[1] ~= vim.fn.line("$") then
            pos_new[1] = pos_new[1] + 1
        end
        -- else set cursor to line after delimiter
        vim.api.nvim_win_set_cursor(0, pos_new)
        return true
    end
    -- we hit EOF
    return false
end

-- Selects lines between start and stop (inclusive).
local function select_lines(start, stop)
    vim.api.nvim_win_set_cursor(0, { start, 0 })
    if not vim.fn.mode():find("V") then
        vim.cmd.normal("V")
    end
    vim.cmd.normal("o")
    vim.api.nvim_win_set_cursor(0, { stop, 0 })
end

-- Selects the current cell.
function M.select_cell(ai_type)
    local extent = delim.get_cell_extent(ai_type)
    select_lines(extent.start, extent.stop)
end

-- Selects from current cell to next cell.
function M.select_to_next_cell(tf_type)
    local line_start = vim.api.nvim_win_get_cursor(0)[1]
    local line_stop
    local pos_next = delim.find_next_delim({ accept_curr = false })
    if pos_next then
        line_stop = pos_next[1]
        if tf_type == "t" then
            line_stop = line_stop - 1
        end
    else
        line_stop = vim.fn.line("$")
    end
    select_lines(line_start, line_stop)
end

-- Selects the next cell.
function M.select_next_cell(ai_type)
    M.cursor_to_next_cell()
    M.select_cell(ai_type)
end

function M.merge_cells(up_down)
    up_down = up_down or 'down'
    local pos_old = vim.api.nvim_win_get_cursor(0)
    local pos_next
    if up_down == 'down' then
        pos_next = delim.find_next_delim({ accept_curr = true })
    else
        pos_next = delim.find_prev_delim({ accept_curr = true })
        pos_old[1] = pos_old[1] - 1
    end
    if pos_next then
        vim.api.nvim_win_set_cursor(0, pos_next)
        vim.cmd.normal('dd')
        vim.api.nvim_win_set_cursor(0, pos_old)
    end
end

function M.put_cell(extra_text)
    extra_text = extra_text or ""
    local pos = vim.api.nvim_win_get_cursor(0)
    local cmt_delim = delim.get_comment_delim()
    local cell_text = cmt_delim.line[1] .. ' ' .. config.options.delimiter
    if cmt_delim.line[2] ~= nil then
        cell_text = cell_text .. ' ' .. cmt_delim.line[2]
    end
    vim.api.nvim_buf_set_lines(0, pos[1], pos[1], false, {cell_text})
end

return M
