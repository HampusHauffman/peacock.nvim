local M = {}

---@class PeacockOptions
---@field priority integer
---@field color_index? integer

local opts = {
  priority = 1,
}

local attached_buffers = {}

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
    local col = vim.fn.win_screenpos(win)[2]
    if col < leftmost_col then
      leftmost_col = col
      result = { win }
    elseif col == leftmost_col then
      table.insert(result, win)
    end
  end

  return result
end

---@param win integer
---@param bufnr integer
---@return boolean
local function is_buf_visible_in_win(win, bufnr)
  return vim.api.nvim_win_get_buf(win) == bufnr
end

---@param bufnr integer
local function set_signcolumn_in_leftmost(bufnr)
  for _, win in ipairs(get_leftmost_windows()) do
    if is_buf_visible_in_win(win, bufnr) then
      vim.api.nvim_set_option_value("signcolumn", "yes", {
        scope = "local",
        win = win,
      })
    end
  end
end

---@param bufnr integer
local function place_signs(bufnr)
  local visible = false

  for _, win in ipairs(get_leftmost_windows()) do
    if is_buf_visible_in_win(win, bufnr) then
      visible = true
      break
    end
  end

  vim.fn.sign_unplace("PeacockSignGroup", { buffer = bufnr })

  if visible then
    local lines = vim.api.nvim_buf_line_count(bufnr)
    for i = 1, lines do
      vim.fn.sign_place(i, "PeacockSignGroup", "PeacockSign", bufnr, {
        lnum = i,
        priority = opts.priority,
      })
    end
  end
end

local function setup_highlights()
  local color = get_dynamic_color()

  vim.api.nvim_set_hl(0, "PeacockDynamic", { fg = color })
  vim.fn.sign_define("PeacockSign", { text = "█", texthl = "PeacockDynamic" })

  vim.opt.fillchars:append({ eob = "█" })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("PeacockHighlightFix", { clear = true }),
    callback = function()
      vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = get_dynamic_color(), bg = "NONE" })
    end,
  })
end

---@param bufnr integer
local function attach_buffer(bufnr)
  if attached_buffers[bufnr] then
    return
  end
  attached_buffers[bufnr] = true

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function()
      place_signs(bufnr)
    end,
  })
end

---@param args { buf: integer }
local function handle_event(args)
  local bufnr = args.buf
  attach_buffer(bufnr)
  set_signcolumn_in_leftmost(bufnr)
end

---Setup Peacock plugin
---@param user_opts? PeacockOptions
function M.setup(user_opts)
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})

  setup_highlights()

  local group = vim.api.nvim_create_augroup("Peacock", { clear = true })

  vim.api.nvim_create_autocmd({
    "TextChanged",
    "TextChangedI",
    "BufReadPost",
    "BufWinEnter",
    "BufWritePost",
    "VimResized",
    "WinEnter",
    "VimResized", -- terminal window resize
    "WinEnter", -- focus moves
    "WinClosed", -- window closed
    "WinNew", -- new window created
  }, {
    group = group,
    callback = function(args)
      handle_event(args)
    end,
  })
end

return M
