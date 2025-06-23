local M = {}

---@class PeacockOptions
---@field priority integer Highlight priority
---@field color_index? integer Optional index to use a specific color instead of dynamic color

-- Default configuration
local opts = {
  priority = 1,
}

-- Internal state
local hl_ns = vim.api.nvim_create_namespace("peacock_ns")
local original_signcolumns = {}

-- 🎨 Custom color palette
local custom_colors = {
  "#f7768e", -- red/pink
  "#e0af68", -- orange/yellow
  "#9ece6a", -- green
  "#7aa2f7", -- blue
  "#bb9af7", -- purple
  "#7dcfff", -- cyan
  "#ffffff", -- white
}

---Generate a deterministic integer from a string
---@param str string
---@return integer
local function string_to_id(str)
  local hash = 0
  for i = 1, #str do
    hash = (hash * 31 + str:byte(i)) % 2 ^ 31
  end
  return hash
end

---Get a color based on the current working directory
---@return string hex_color
local function get_dynamic_color()
  if opts.color_index then
    return custom_colors[(opts.color_index - 1) % #custom_colors + 1]
  end
  local id = string_to_id(vim.fn.getcwd())
  return custom_colors[(id % #custom_colors) + 1]
end

---Find the leftmost windows on the screen
---@return integer[] win_ids
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

---Setup highlights using the dynamic color
local function setup_highlights()
  local color = get_dynamic_color()

  vim.api.nvim_set_hl(hl_ns, "SignColumn", { bg = color, priority = opts.priority })
  vim.api.nvim_set_hl(hl_ns, "EndOfBuffer", { fg = color, bg = "NONE", priority = opts.priority })
  vim.api.nvim_set_hl(0, "PeacockDynamic", { fg = color })

  vim.opt.fillchars:append({ eob = "█" })
end

---Update window highlights and signcolumn behavior for leftmost windows
local function update_window_highlights()
  local leftmost = get_leftmost_windows()

  -- Set of windows that are left aligned
  local win_set = {}
  for _, win in ipairs(leftmost) do
    win_set[win] = true
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win_set[win] then
      if not original_signcolumns[win] then
        local current = vim.api.nvim_get_option_value("signcolumn", { win = win })
        original_signcolumns[win] = current
      end
      vim.api.nvim_set_option_value("signcolumn", "yes:1", { win = win })
      vim.api.nvim_win_set_hl_ns(win, hl_ns)
    else
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

  setup_highlights()
  update_window_highlights()

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
        update_window_highlights()
        vim.defer_fn(update_window_highlights, 30)
      end)
    end,
  })
end

return M
