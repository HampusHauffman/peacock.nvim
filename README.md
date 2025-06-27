# 🦚 peacock.nvim

**Add flair to your focus.**  
Peacock.nvim dynamically highlights the **leftmost window** in your Neovim layout using vibrant colors derived from your current working directory.

It’s a subtle but effective visual anchor, especially helpful in split-heavy workflows — and highly customizable for a themed experience.

![peacock demo](https://user-images.githubusercontent.com/your-demo-gif-url.gif)
<img width="1512" alt="Screenshot of peacock.nvim in action" src="https://github.com/user-attachments/assets/54481711-945d-41e3-8c79-18aecfc6b4d5" />

---

## ✨ Features

- 🎨 **Dynamic color assignment** based on your working directory
- 🪟 **Leftmost window highlighting** using `SignColumn` and optional `EndOfBuffer` styling
- 📐 **Custom sign column width** for aligned UI
- 🧠 **Hash-based palette selection** — consistent per project
- 🪄 **Automatic updates** on common window/buffer events
- 🔧 **Optional configuration** — works out of the box
- 🎛️ **Reusable highlight groups** for your own UI theming

---

## 🚀 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "hampushauffman/peacock.nvim",
  name = "peacock",
  dir = "~/Documents/peacock.nvim", -- optional if developing locally
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
🔧 Options
Option	Type	Default	Description
colors	string[]	Built-in	A list of hex color strings. One will be chosen per project based on hash.
sign_column_width	number	1	Width of the left signcolumn for highlighted windows.
bar_enabled	boolean	true	Whether to enable Peacock’s left-bar highlighting.
eob_enabled	boolean	true	Whether to replace and color the EndOfBuffer (~) characters.

📸 When does it update?
Peacock updates dynamically on:

WinEnter, WinLeave

BufWinEnter, BufWinLeave

WinNew, VimResized

This ensures your leftmost window remains styled correctly as splits change.

🧪 Example Setups
Minimal setup
lua
Kopiera
Redigera
require("peacock").setup()
Disable EOB character styling
lua
Kopiera
Redigera
require("peacock").setup({
  eob_enabled = false,
})
Custom palette + wide sign column
lua
Kopiera
Redigera
require("peacock").setup({
  sign_column_width = 2,
  colors = { "#ff6b6b", "#feca57", "#48dbfb", "#1dd1a1" },
})
🎨 Advanced Usage: Link Peacock Highlights
Peacock defines three core highlight groups:

Highlight Group	Description
PeacockFg	Foreground color (based on project)
PeacockBg	Background color (based on project)
Peacock	Both fg and bg combined

You can use these to color other parts of your UI (e.g., floating borders, line numbers, lualine, etc.):

lua
Kopiera
Redigera
require("peacock").setup()

local nvim_set_hl = vim.api.nvim_set_hl

-- Apply Peacock color to UI components
nvim_set_hl(0, "WinSeparator", { link = "PeacockFg" })
nvim_set_hl(0, "FloatBorder", { link = "PeacockFg" })
nvim_set_hl(0, "LineNr", { link = "PeacockFg" })

-- Apply Peacock to lualine (if installed)
nvim_set_hl(0, "lualine_a_normal", { link = "PeacockBg" })
nvim_set_hl(0, "lualine_b_normal", { link = "PeacockFg" })

-- Transitional groups might require deferred application
vim.schedule(function()
  nvim_set_hl(
    0,
    "lualine_transitional_lualine_a_normal_to_StatusLine",
    { link = "PeacockFg" }
  )
end)
You can also extract the hex color from the highlight group if you want to generate your own styles.
