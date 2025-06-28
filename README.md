# 🦚 peacock.nvim

![Screenshot 2025-06-27 at 21 46 40_transparent](https://github.com/user-attachments/assets/f109f6a3-0e76-4dda-9050-326b96424e37)
![Screenshot 2025-06-27 at 21 46 40_2](https://github.com/user-attachments/assets/d98c6466-2f97-468e-81c2-fa9c2f967789)

### Peacock.nvim highlights your different projects in neovim. 
Each project's color is based on its path meaning each project will keep its own color as long as the path remains the same.

## 🚀 Simple Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "hampushauffman/peacock.nvim",
  lazy = false,
  config = function()
    require("peacock").setup()
  end,
}
```
## ⚙️ Configuration
Peacock accepts an optional setup table.

```lua
require("peacock").setup({
  colors = { -- Colors that you'd like to use instead of the defaults.
    "#fca5a5",
    "#fdba74",
    "#fcd34d",
    "#fde047",
    "#bef264",
    "#86efac",
    "#6ee7b7",
    "#5eead4",
    "#67e8f9",
    "#7dd3fc",
    "#93c5fd",
    "#a5b4fc",
    "#c4b5fd",
    "#d8b4fe",
    "#f0abfc",
    "#f9a8d4",
    "#fda4af",
  },
  bar_enabled = true, -- When this is enabled (default) the left most window will show its signcolumn with the project color.
  sign_column_width = 1, -- This is the width of the bar sowhing in the left most window.
  eob_enabled = true, -- To give a more unified look we set the eob character to █ and color it to the project color
})
```

### Highlight Group	Description:
Highlight groups defined by peacock can be used to color more than the signcolumn.

* **PeacockFg**	Foreground color (based on project)

* **PeacockBg**	Background color (based on project)

* **Peacock**	Both fg and bg combined

You can color other parts of your UI (e.g., floating borders, line numbers, lualine, etc.):
```lua
require("peacock").setup()

local nvim_set_hl = vim.api.nvim_set_hl
-- Apply Peacock color to other UI components
nvim_set_hl(0, "WinSeparator", { link = "PeacockFg" })
nvim_set_hl(0, "FloatBorder", { link = "PeacockFg" })
nvim_set_hl(0, "LineNr", { link = "PeacockFg" })

```
