# 🦚 peacock.nvim

**A fabulous Neovim plugin that colors your leftmost window with style.**  
Dynamic highlights based on your current directory.  
Make your workspace pop — like a peacock strutting through your splits.

![peacock demo](https://user-images.githubusercontent.com/your-demo-gif-url.gif)

---

## ✨ Features

- 🎨 Automatically assigns unique colors to your Neovim workspace based on the working directory
- 🪟 Highlights the **leftmost window** with a colorful `SignColumn` and `EndOfBuffer`
- 🎯 Zero configuration required — plug and shine
- 💫 Respects your splits and updates dynamically with events like buffer enter, resize, etc.
- 🧠 Hash-based coloring ensures a consistent yet unique theme per project

---

## 🚀 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yourusername/peacock.nvim",
  config = function()
    require("peacock").setup()
  end,
}
