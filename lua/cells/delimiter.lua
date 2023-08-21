local Ft = require('Comment.ft')
local Config = require('cells.config')

local M = {}

-- Gets the valid comment delim (line and block) for the current filetype
function M.get_comment_delim()
    local cmt_str_line = Ft.get(vim.bo.filetype)[1]
    local cmt_str_block = Ft.get(vim.bo.filetype)[2]
    local delim = {}
    delim.line = vim.split(cmt_str_line, '%s', { plain = true })
    if cmt_str_block then
        delim.block = vim.split(cmt_str_block, '%s', { plain = true })
    end
    return delim
end

function M.create_cell_regex()
    local cmt = M.get_comment_delim()
    local cell = Config.cell_delimiter

    -- Let d1, d2 denote escaped comment delim and c the escaped cell delim,
    -- then the basic regex is: ^d1\s*c  and if d2 exists we add .*d2\s*$
    -- Here we define one such regex for line comments (rl) and one for block comments
    -- (rb) and put them together: (rl|rb). Note that in the code we actually use
    -- vim's non-magic mode so all non-alpha characters have to be escaped.
    local regex = [[\V\^]] .. cmt.line[1] .. [[\s\*]] .. cell
    if cmt.line[2] ~= '' then
        regex = regex .. [[\.\*]] .. cmt.line[2] .. [[\s\*\$]]
    end

    if cmt.block and cmt.block ~= cmt.line then
        local regex_block = [[\V\^]] .. cmt.block[1] .. [[\s\*]] .. cell
        regex_block = regex_block .. [[\.\*]] .. cmt.block[2] .. [[\s\*\$]]
        regex = [[\(]] .. regex .. [[\|]] .. regex_block .. [[\)]]
    end

    return regex
end

function M.find_prev_delim(move_cursor, accept_curr, cell_regex)
    local flags = 'Wb'
    flags = move_cursor and flags or flags .. 'n'
    flags = flags .. (accept_curr and 'c' or 'z')
    cell_regex = cell_regex or M.create_cell_regex()

    -- find prev cell delim
    local line = vim.fn.search(cell_regex, flags, 1)
    local pos_new = { line, 0 }
    if line == 0 then
        pos_new = nil
    end
    return pos_new
end

function M.find_next_delim(move_cursor, accept_curr, cell_regex)
    local flags = 'W'
    flags = move_cursor and flags or flags .. 'n'
    flags = accept_curr and flags .. 'c' or flags
    cell_regex = cell_regex or M.create_cell_regex()

    -- move cursor to starting position for forward search
    local pos_old = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, { pos_old[1], 0 })

    -- move to next cell delim
    local to_line = vim.fn.search(cell_regex, flags)
    local pos_new = { to_line, 0 }
    if to_line == 0 or move_cursor == false then
        vim.api.nvim_win_set_cursor(0, pos_old)
    end
    if to_line == 0 then
        return nil
    else
        return pos_new
    end
end

-- Moves the cursor to the first line of the prev cell.
function M.cursor_to_prev_cell()
    local cell_regex = M.create_cell_regex()

    -- first backward search: accept match at curr line after this
    -- we are guaranteed to be at the delim of the curr cell
    local pos_new = M.find_prev_delim(true, true, cell_regex)
    if pos_new then
        vim.api.nvim_win_set_cursor(0, pos_new)

        -- second backward search: takes us to the delim of the prev cell
        pos_new = M.find_prev_delim(true, false, cell_regex)
        if pos_new then
            pos_new[1] = pos_new[1] + 1
            vim.api.nvim_win_set_cursor(0, pos_new)
            return pos_new
        end
    end

    -- If one or both backward searches failed: go back to the start.
    pos_new = { 1, 0 }
    vim.api.nvim_win_set_cursor(0, pos_new)
    return pos_new
end

-- Moves the cursor to the first line of the next cell.
function M.cursor_to_next_cell()
    local cell_regex = M.create_cell_regex()

    local pos_new = M.find_next_delim(false, false, cell_regex)
    if pos_new then
        pos_new[1] = pos_new[1] + 1
        vim.api.nvim_win_set_cursor(0, pos_new)
    end
    return pos_new
end

-- Find the region that corresponds to the nearest cell
-- ai_type: 'i' or 'a' for inner or around
function M.get_cell_region(ai_type)
    local cell_regex = M.create_cell_regex()
    local pos_old = vim.api.nvim_win_get_cursor(0)

    -- move cursor to starting position for backward search
    vim.api.nvim_win_set_cursor(0, { pos_old[1], vim.fn.col('$') })

    -- find prev cell delim or BOF, don't move cursor
    local from_line = vim.fn.search(cell_regex, 'ncWb', 1) + 1
    if from_line > 1 and ai_type == 'a' then
        from_line = from_line - 1
    end

    -- find next cell delim or EOF, move cursor
    local num_lines = vim.api.nvim_buf_line_count(0)
    local to_line = vim.fn.search(cell_regex, 'W', num_lines)
    to_line = to_line == 0 and num_lines or to_line - 1
    vim.api.nvim_win_set_cursor(0, { to_line, 0 })

    -- define the region and move cursor back
    local from = { line = from_line, col = 1 }
    local to = { line = to_line, col = vim.fn.col('$') }
    vim.api.nvim_win_set_cursor(0, pos_old)
    return { from = from, to = to }
end

return M
