local ft = require('Comment.ft')
local Config = require('cells.config')


-- @module M
local M = {}


-- Gets the valid comment delimiters (line and block) for the current filetype
function M.get_comment_delimiters()
    local cmtstr_line = ft.get(vim.bo.filetype)[1]
    local cmtstr_block = ft.get(vim.bo.filetype)[2]
    local delims = {}
    -- delims.line = string_split(cmtstr_line, '%s')
    delims.line = vim.split(cmtstr_line, '%s', {plain=true})
    if cmtstr_block then
        delims.block = vim.split(cmtstr_block, '%s', {plain=true})
    end
   return delims
end

function M.create_cell_regex()
    local cmt = M.get_comment_delimiters()
    local cell = Config.cell_delimiter

    -- Regexes
    -- Let d1, d2 denote escaped comment delimiters and c the escaped cell delimiter,
    -- then the basic regex is: ^d1\s*c  and if d2 exists we add .*d2\s*$
    -- Here we define one such regex for line comments (rl) and one for block comments
    -- (rb) and put them together: (rl|rb). Note that in the code we actually use
    -- vim's non-magic mode so all non-alpha characters have to be escaped.
    local regex = [[\V\^]] .. cmt.line[1] .. [[\s\*]] .. cell
    if cmt.line[2] ~= '' then
        regex = regex .. [[\.\*]] .. cmt.line[2] .. [[\s\*\$]]
    end

    if cmt.block and cmt.block ~= cmt.line then
        local regex_b = [[\V\^]] .. cmt.block[1] .. [[\s\*]] .. cell
        regex_b = regex_b .. [[\.\*]] .. cmt.block[2] .. [[\s\*\$]]
        regex = [[\(]] .. regex .. [[\|]] .. regex_b .. [[\)]]
    end

    return regex
end

function M.find_previous_delimiter(move_cursor, current_line_ok, cell_regex)
    local search_flags = 'Wb'
    search_flags = move_cursor and search_flags or search_flags .. 'n'
    search_flags = search_flags .. (current_line_ok and 'c' or 'z')
    cell_regex = cell_regex or M.create_cell_regex()

    -- find previous cell delim
    local line = vim.fn.search(cell_regex, search_flags, 1)
    local pos_new = {line, 0}
    if line == 0 then
        pos_new = nil
    end
    return pos_new
end

function M.find_next_delimiter(move_cursor, match_current_line, cell_regex)
    local search_flags = 'W'
    search_flags = move_cursor and search_flags or search_flags .. 'n'
    search_flags = match_current_line and search_flags .. 'c' or search_flags
    cell_regex = cell_regex or M.create_cell_regex()

    -- move cursor to starting position for forward search
    local pos_old = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, {pos_old[1], 0})

    -- move to next cell delim
    local to_line = vim.fn.search(cell_regex, search_flags)
    local pos_new = {to_line, 0}
    if to_line == 0 or move_cursor == false then
        vim.api.nvim_win_set_cursor(0, pos_old)
    end
    if to_line == 0 then
        return nil
    else
        return pos_new
    end
end

-- Moves the cursor to the first line of the previous cell.
function M.cursor_to_previous_cell()
    local cell_regex = M.create_cell_regex()

    -- first backward search: accept match at current line after this
    -- we are guaranteed to be at the delimiter of the current cell
    local pos_new = M.find_previous_delimiter(true, true, cell_regex)
    if pos_new then
        vim.api.nvim_win_set_cursor(0, pos_new)
        
        -- second backward search: takes us to the delimiter of the previous cell 
        pos_new = M.find_previous_delimiter(true, false, cell_regex)
        if pos_new then
            pos_new[1] = pos_new[1] + 1
            vim.api.nvim_win_set_cursor(0, pos_new)
            return pos_new
        end
    end

    -- If one or both backward searches failed: go back to the start.
    pos_new = {1, 0}
    vim.api.nvim_win_set_cursor(0, pos_new)
    return pos_new
end

-- Moves the cursor to the first line of the next cell.
function M.cursor_to_next_cell()
    local cell_regex = M.create_cell_regex()

    local pos_new = M.find_next_delimiter(false, false, cell_regex)
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
    vim.api.nvim_win_set_cursor(0, {pos_old[1], vim.fn.col('$')})

    -- find previous cell delim or BOF, don't move cursor
    local from_line = vim.fn.search(cell_regex, 'ncWb', 1) + 1
    if from_line > 1 and ai_type == 'a' then
        from_line = from_line - 1
    end

    -- find next cell delim or EOF, move cursor
    local nlines = vim.api.nvim_buf_line_count(0)
    local to_line = vim.fn.search(cell_regex, 'W', nlines)
    to_line = to_line == 0 and nlines or to_line - 1
    vim.api.nvim_win_set_cursor(0, {to_line, 0})
    
    -- define the region and move cursor back
    local from = {line = from_line, col = 1}
    local to = {line = to_line, col = vim.fn.col('$')}
    vim.api.nvim_win_set_cursor(0, pos_old)
    return {from = from, to = to}
end

