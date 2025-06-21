local M = {}

---@class PeacockOptions
---@field priority integer
---@field color_index? integer

local opts = {
  priority = 1,
}

local attached_buffers = {}
local hl_ns = vim.api.nvim_create_namespace("peacock_ns")

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

---@param str string
---@return integer
local function string_to_id(str)
  local hash = 0
  for i = 1, #str do
    hash = (hash * 31 + str:byte(i)) % 2 ^ 31
  end
  return hash
end

---@return string
local function get_dynamic_color()
  local id = string_to_id(vim.fn.getcwd())
  return custom_colors[(id % #custom_colors) + 1]
end

---@return integer[]
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

local function setup_highlights()
  local color = get_dynamic_color()

  -- Define custom highlights inside the namespace
  vim.api.nvim_set_hl(hl_ns, "SignColumn", { bg = color })
  vim.api.nvim_set_hl(hl_ns, "EndOfBuffer", { fg = color, bg = "NONE" })

  vim.api.nvim_set_hl(0, "PeacockDynamic", { fg = color })
  vim.fn.sign_define("PeacockSign", { text = "█", texthl = "PeacockDynamic" })

  vim.opt.fillchars:append({ eob = "█" })

  vim.api.nvim_set_hl(hl_ns, "EndOfBuffer", { fg = get_dynamic_color(), bg = "NONE" })
end

local function update_window_highlights()
  local leftmost = get_leftmost_windows()
  local win_set = {}
  for _, win in ipairs(leftmost) do
    win_set[win] = true
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win_set[win] then
      vim.api.nvim_set_option_value("signcolumn", "yes:1", { win = win })
      vim.api.nvim_win_set_hl_ns(win, hl_ns) -- applies SignColumn and EndOfBuffer
    else
      vim.api.nvim_win_set_hl_ns(win, 0) -- fallback to global
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
      vim.schedule(update_window_highlights)
    end,
  })
end

return M
