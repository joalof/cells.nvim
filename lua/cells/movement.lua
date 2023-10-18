local delim = require("cells.delimiter")

M = {}

-- Moves the cursor to the first line of the prev cell.
-- Only moves the cursor if there is a cell above.
function M.cursor_to_prev_cell()
    -- first backward search: accept match at curr line after this
    -- we are guaranteed to be at the delim of the curr cell
    local pos_new = delim.find_prev_delim({ accept_curr = true })
    if pos_new then
        -- if file started with a delimiter: return early and dont move
        if pos_new[1] == 1 then
            return
        end
        -- at least one cell above, move cursor
        vim.api.nvim_win_set_cursor(0, pos_new)

        -- second backward search: takes us to the delim of the prev cell
        pos_new = M.find_prev_delim({ accept_curr = false })
        if pos_new then
            pos_new[1] = pos_new[1] + 1
            vim.api.nvim_win_set_cursor(0, pos_new)
            return
        end
    end
end

-- Moves the cursor to the first line of the next cell.
-- Only moves the cursor if there is a cell below.
function M.cursor_to_next_cell()
    local pos_new = delim.find_next_delim({ accept_curr = false })
    if pos_new then
        -- if we hit EOF return
        if pos_new[1] == vim.fn.line("$") then
            return
        end
        -- else set cursor to line after delimiter
        pos_new[1] = pos_new[1] + 1
        vim.api.nvim_win_set_cursor(0, pos_new)
    end
end
