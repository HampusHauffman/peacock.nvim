local M = {}

local opts = {
  priority = 1,
}

local attached_buffers = {}

-- 🎨 Define your own color palette (edit freely)
local custom_colors = {
  "#f7768e", -- 1 - red/pink
  "#e0af68", -- 2 - orange/yellow
  "#9ece6a", -- 3 - green
  "#7aa2f7", -- 4 - blue
  "#bb9af7", -- 5 - purple
  "#7dcfff", -- 6 - cyan
  "#ffffff", -- 7 - white
}

--- Place a █ sign on every line in the current buffer.
function M.place_signs(bufnr)
  -- ⬅️ Ensure signcolumn is always on in this buffer
  vim.api.nvim_set_option_value("signcolumn", "yes", { scope = "local" })

  local line_count = vim.api.nvim_buf_line_count(bufnr)

  vim.fn.sign_unplace("PeacockSignGroup", { buffer = bufnr })

  for i = 1, line_count do
    vim.fn.sign_place(i, "PeacockSignGroup", "PeacockSign", bufnr, {
      lnum = i,
      priority = opts.priority,
    })
  end
end

local function string_to_id(str)
  local hash = 0
  for i = 1, #str do
    hash = (hash * 31 + str:byte(i)) % 2 ^ 31
  end
  return hash
end

--- Setup Peacock plugin
---@param user_opts? { priority?: number, color_index?: number }
function M.setup(user_opts)
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})

  local current_dir = vim.fn.getcwd()
  local id = string_to_id(current_dir)
  local color = custom_colors[id % #custom_colors]

  -- Define dynamic highlight group
  vim.api.nvim_set_hl(0, "PeacockDynamic", { fg = color })

  -- Apply to EndOfBuffer and to signs
  vim.opt.fillchars:append({ eob = "█" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { link = "PeacockDynamic" })

  vim.fn.sign_define("PeacockSign", {
    text = "█",
    texthl = "PeacockDynamic",
  })

  -- Autocmd group for refresh
  local group = vim.api.nvim_create_augroup("Peacock", { clear = true })

  local function update_peacock()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)

      -- 📌 Only attach once per buffer
      if not attached_buffers[buf] then
        attached_buffers[buf] = true
        vim.api.nvim_buf_attach(buf, false, {
          on_lines = function()
            pcall(M.place_signs, buf)
          end,
        })
      end

      pcall(M.place_signs, buf)
    end
  end

  vim.api.nvim_create_autocmd({
    "TextChanged",
    "TextChangedI",
    "BufReadPost",
    "BufWinEnter",
    "BufWritePost",
    "VimResized",
    "WinEnter",
  }, {
    group = group,
    callback = function()
      update_peacock()
    end,
  })

  -- Initial signs for current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  pcall(M.place_signs, current_buf)
end

return M
