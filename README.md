# cells.nvim
**cells.nvim** is a minimal Neovim plugin for partitioning code into **cells**, which can be used for navigation and communicating chunks of code to jupyter kernels/REPls via plugins such as [molten.nvim](https://github.com/benlubas/molten.nvim), [iron.nvim](https://github.com/hkupty/iron.nvim), or [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim). The plugin provides a cell text object and some utility functions for cell manipulation.


## 📦 What is a cell?
A **cell** is a contiguous block of code, typically used as a unit of execution. In `cells.nvim`, a cell is bounded by a comment containing a pre-designated **delimiter** (by default `%%`). The beginning and end of a file (BOF/EOF) are also considered implicit cell boundaries.

For example, in Python:

```python
print("This is cell 1")

# %%
print("This is cell 2")

print("Still in cell 2")

# %%
print('Cell 3 now')
```

## 🔌 Installation
Install with you favourite plugin manager, for example with [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "joalof/cells.nvim",
    config = function()
        -- if you want cells to automatically setup the cell textobject
        -- you can provide a symbol here, otherwise leave empty
        require("cells").setup({
            textobject = "d", 
        })
        -- example keybinds for navigation functions
        vim.keymap.set("n", "]d", function()
            require("cells.editing").cursor_to_next_cell()
        end, { silent = true })
        vim.keymap.set("n", "[d", function()
            require("cells.editing").cursor_to_prev_cell()
        end, { silent = true })
    end,


}
```

## 🔧 Related Plugins
[NotebookNavigator.nvim](https://github.com/GCBallesteros/NotebookNavigator.nvim) provides richer integrations and features. In contrast, **cells.nvim** is intentionally minimal and dependency-free.

## 🙏 Credits
- [Comment.nvim](https://github.com/numToStr/Comment.nvim) by @numToStr from which I yoinked the extensive list of commentstrings.
