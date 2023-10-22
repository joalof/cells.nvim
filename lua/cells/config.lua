local M = {}

local defaults = {
    cell_delimiter = "%%",
    cell_separator = "─",
    cell_textobject = nil,
}

M.options = defaults

local function create_mappings(textobj)
    -- inner/around
    for _, ai_type in ipairs({ "a", "i" }) do
        -- current cell
        vim.keymap.set({ "o", "x" }, ai_type .. textobj, function()
            require("cells.editing").select_cell(ai_type)
        end, { silent = true })

        -- next cell
        vim.keymap.set({ "o", "x" }, ai_type .. "n" .. textobj, function()
            require("cells.editing").select_next_cell(ai_type)
        end, { silent = true })
    end

    -- to/find next cell
    for _, tf_type in ipairs({ "t", "f" }) do
        vim.keymap.set("o", tf_type .. textobj, function()
            require("cells.editing").select_to_next_cell(tf_type)
        end, { silent = true })
    end
end

function M.configure(opts)
    opts = opts or {}
    M.options = vim.tbl_deep_extend("force", defaults, opts)

    if M.options.cell_textobject then
        create_mappings(M.options.cell_textobject)
    end
end

return M
