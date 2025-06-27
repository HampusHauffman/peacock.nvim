# 🦚 peacock.nvim

**Add flair to your focus.**  
Peacock.nvim dynamically highlights the **leftmost window** in your Neovim layout using vibrant colors derived from your current working directory.

It’s a subtle but effective visual anchor, especially helpful in split-heavy workflows — and highly customizable for a themed experience.

![peacock demo](https://user-images.githubusercontent.com/your-demo-gif-url.gif)
<img width="1500" alt="Screenshot 2025-06-27 at 21 46 40" src="https://github.com/user-attachments/assets/fd67dffe-4eb6-4b12-9c25-97195023031c" />


## 🚀 Installation

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
⚙️ Configuration
Peacock accepts an optional setup table.

```lua
require("peacock").setup({
  colors = {
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
  sign_column_width = 1,
  bar_enabled = true,
  eob_enabled = true,
})
```

### Highlight Group	Description:
**PeacockFg**	Foreground color (based on project)
**PeacockBg**	Background color (based on project)
**Peacock**	Both fg and bg combined

You can use these to color other parts of your UI (e.g., floating borders, line numbers, lualine, etc.):
```lua
require("peacock").setup()

local nvim_set_hl = vim.api.nvim_set_hl
-- Apply Peacock color to other UI components
nvim_set_hl(0, "WinSeparator", { link = "PeacockFg" })
nvim_set_hl(0, "FloatBorder", { link = "PeacockFg" })
nvim_set_hl(0, "LineNr", { link = "PeacockFg" })

```
