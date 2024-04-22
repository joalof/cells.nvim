local comment_ft = require("Comment.ft")

local M = {}

-- Gets the valid comment delim (line and block) for the current filetype.
function M.get_comment_delim()
    local cmt_str_line = comment_ft.get(vim.bo.filetype)[1]
    local cmt_str_block = comment_ft.get(vim.bo.filetype)[2]
    local cmt_delim = {}
    cmt_delim.line = vim.split(cmt_str_line, "%s", { plain = true })
    if cmt_str_block then
        cmt_delim.block = vim.split(cmt_str_block, "%s", { plain = true })
    end
    return cmt_delim
end

-- Creates a regex that will match comments with cell delimiters.
function M.create_delim_regex()
    local cmt = M.get_comment_delim()
    local cell = require("cells.config").options.delimiter

    -- Let d1, d2 denote escaped comment delim and c the escaped cell delim,
    -- then the basic regex is: ^d1\s*c  and if d2 exists we add .*d2\s*$
    -- Here we define one such regex for line comments (rl) and one for block comments
    -- (rb) and put them together: (rl|rb). Note that in the code we actually use
    -- vim's non-magic mode so all non-alpha characters have to be escaped.
    local regex = [[\V\^]] .. cmt.line[1] .. [[\s\*]] .. cell
    if cmt.line[2] ~= "" then
        regex = regex .. [[\.\*]] .. cmt.line[2] .. [[\s\*\$]]
    end

    if cmt.block and cmt.block ~= cmt.line then
        local regex_block = [[\V\^]] .. cmt.block[1] .. [[\s\*]] .. cell
        regex_block = regex_block .. [[\.\*]] .. cmt.block[2] .. [[\s\*\$]]
        regex = [[\(]] .. regex .. [[\|]] .. regex_block .. [[\)]]
    end

    return regex
end

-- Cache delimiter regexes by filetype here for a slight speedup.
local regex_cache = {}

-- Lazily get delimiter regex using cache if available for the current ft.
function M.get_delim_regex()
    local ft_curr = vim.filetype.match({ filename = vim.api.nvim_buf_get_name(0) })
    local regex = regex_cache[ft_curr]
    if not regex then
        regex = M.create_delim_regex()
        regex_cache[ft_curr] = regex
    end
    return regex
end

function M.find_prev_delim(opts)
    opts = opts or {}
    local flags = "Wbn"
    flags = flags .. (opts.accept_curr and "c" or "z")
    local delim_regex = M.get_delim_regex()

    -- find prev cell delim
    local line = vim.fn.search(delim_regex, flags, 1)
    local pos_new = { line, 0 }
    if line == 0 then
        pos_new = nil
    end
    return pos_new
end

function M.find_next_delim(opts)
    opts = opts or {}
    local flags = "Wn"
    flags = opts.accept_curr and flags .. "c" or flags
    local delim_regex = M.get_delim_regex()

    -- move cursor to starting position for forward search
    local pos_old = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, { pos_old[1], 0 })

    -- move to next cell delim
    local to_line = vim.fn.search(delim_regex, flags)
    local pos_new = { to_line, 0 }
    vim.api.nvim_win_set_cursor(0, pos_old)
    if to_line == 0 then
        pos_new = nil
    end
    return pos_new
end

function M.get_cell_extent(ai_type)
    local pos_prev = M.find_prev_delim({ accept_curr = true })
    local line_start
    local line_stop

    -- Find start of the cell, if ai_type is "i"
    -- dont include the starting cell delimiter.
    if pos_prev then
        line_start = pos_prev[1]
        if ai_type == "i" then
            line_start = line_start + 1
        end
    else -- if no match then start from BOF
        line_start = 1
    end

    -- Find the end of the cell, the final
    -- cell delimiter is never a part of the cell.
    local pos_next = M.find_next_delim()
    if pos_next then
        line_stop = pos_next[1] - 1
    else
        line_stop = vim.fn.line("$")
    end
    return { start = line_start, stop = line_stop }
end

return M
