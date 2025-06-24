local M = {}

---@class PeacockOptions
---@field colors string[] List of colors to use
local opts = {
  colors = {
    "#f7768e", -- red/pink
    "#e0af68", -- orange/yellow
    "#9ece6a", -- green
    "#7aa2f7", -- blue
    "#bb9af7", -- purple
    "#7dcfff", -- cyan
    "#ffffff", -- white
  },
}

local hl_ns = vim.api.nvim_create_namespace("peacock_ns")

---Convert string to int
---@param str string
---@return integer
local function string_to_id(str)
  local hash = 0
  for i = 1, #str do
    hash = (hash * 31 + str:byte(i)) % 2 ^ 31
  end
  return hash
end

---Get one of the colors available based of the current dir
---@return string
local function get_dynamic_color()
  local id = string_to_id(vim.fn.getcwd())
  return opts.colors[(id % #opts.colors) + 1]
end

---Get the left most windows id in an array
---@return integer[] All the id's of windows that are 0 column aligned
local function get_leftmost_windows()
  local leftmost_col = math.huge
  local result = {}

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ok, col = pcall(function()
      return vim.fn.win_screenpos(win)[2]
    end)
    if ok then
      if col < leftmost_col then
        leftmost_col = col
        result = { win }
      elseif col == leftmost_col then
        table.insert(result, win)
      end
    end
  end

  return result
end

---Setup function to create the different highlights needed and set up eol sign
local function setup_highlights()
  local color = get_dynamic_color()
  local nvim_set_hl = vim.api.nvim_set_hl

  nvim_set_hl(0, "PeacockFg", { fg = color }) -- vertical splits
  nvim_set_hl(0, "PeacockBg", { bg = color }) -- vertical splits
  nvim_set_hl(0, "Peacock", { fg = color, bg = color  }) -- vertical splits

  -- Default namespaces
  nvim_set_hl(0, "WinSeparator", { fg = color }) -- vertical splits
  nvim_set_hl(0, "FloatBorder", { fg = color }) -- floating window border

  -- Left aligned window namespace
  nvim_set_hl(hl_ns, "EndOfBuffer", { fg = color, bg = "NONE" })
  nvim_set_hl(hl_ns, "SignColumn", { bg = color })
  nvim_set_hl(hl_ns, "EndOfBuffer", { fg = color, bg = "NONE" })

  vim.opt.fillchars:append({ eob = "█" })

  -- Re-apply dynamic EOB color
end

local original_signcolumns = {}

---Updates the highlights
---This saves current SignColumn settings for a window
---If window is on the left side sets the ns_id of window to one with a unique color
---Else resets window SignColumn setting
local function update_window_highlights()
  local leftmost = get_leftmost_windows()
  local win_set = {}
  for _, win in ipairs(leftmost) do
    win_set[win] = true
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win_set[win] then
      -- Store original signcolumn if not already saved
      if not original_signcolumns[win] then
        local current_value = vim.api.nvim_get_option_value("signcolumn", { win = win })
        original_signcolumns[win] = current_value
      end
      vim.api.nvim_set_option_value("signcolumn", "yes:1", { win = win })
      vim.api.nvim_win_set_hl_ns(win, hl_ns)
    else
      -- Restore signcolumn only if it was changed
      if original_signcolumns[win] then
        pcall(vim.api.nvim_set_option_value, "signcolumn", original_signcolumns[win], { win = win })
        original_signcolumns[win] = nil
      end
      vim.api.nvim_win_set_hl_ns(win, 0)
    end
  end
end

---Setup Peacock plugin
---@param user_opts? PeacockOptions
function M.setup(user_opts)
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})

  local group = vim.api.nvim_create_augroup("Peacock", { clear = true })

  vim.api.nvim_create_autocmd({
    "WinEnter",
    "WinLeave",
    "WinNew",
    "VimResized",
    "BufWinEnter",
    "BufWinLeave",
  }, {
    group = group,
    callback = function()
      vim.schedule(function()
        setup_highlights()
        update_window_highlights()
        -- Seems we need this since i've had issues with some file
        -- manager plugin buffers setting Sign column values after initiation
        vim.defer_fn(function()
          update_window_highlights()
        end, 30)
      end)
    end,
  })
end

return M
