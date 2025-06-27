local M = {}

---@class PeacockOptions
---@field colors string[] List of colors to use
---@field sign_column_width number The width of the peacock column / sign column. This is also what each window will reset to after being left aligned
---@field bar_enabled boolean Whether or not to show the left bar
local opts = {
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
  nvim_set_hl(0, "Peacock", { fg = color, bg = color }) -- vertical splits

  -- Left aligned window namespace
  nvim_set_hl(hl_ns, "EndOfBuffer", { fg = color, bg = "NONE" })
  nvim_set_hl(hl_ns, "SignColumn", { bg = color })

  if opts.eob_enabled then
    nvim_set_hl(hl_ns, "EndOfBuffer", { fg = color, bg = "NONE" })
    vim.opt.fillchars:append({ eob = "█" })
  end

  -- Re-apply dynamic EOB color
end

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
      local current_val = vim.api.nvim_get_option_value("signcolumn", { win = win })
      -- Only set to "yes:1" if current value does NOT include a digit (i.e., not already reserving space)
      if not string.find(current_val, "%d") then
        vim.api.nvim_set_option_value("signcolumn", "yes:" .. opts.sign_column_width, { win = win })
      end
      vim.api.nvim_win_set_hl_ns(win, hl_ns)
    else
      vim.api.nvim_win_set_hl_ns(win, 0)
    end
  end
end

---Setup Peacock plugin
---@param user_opts? PeacockOptions
function M.setup(user_opts)
  setup_highlights()
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})

  local group = vim.api.nvim_create_augroup("Peacock", { clear = true })

  if not opts.bar_enabled then
    return
  end
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
