-- codeberg.lua
-- A Neovim theme based on Codeberg/Forgejo

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "codeberg"

local colors = {
  bg         = "#04121b",
  status_bg  = "#0c1a24",
  fg         = "#c9d1d9",
  visual     = "#1d4057",
  line_nr    = "#304f64",
  cursorline = "#082437",
  split      = "#1d4057",
  pmenu_bg   = "#061825",

  yellow     = "#ffaa10",
  orange     = "#ff7540",
  gold       = "#fabd2f",
  blue       = "#649bc4",
  green      = "#b8bb26",
  green_alt  = "#8ec07c",
  grey_light = "#c9d1d9",
  grey_dark  = "#777e94",
  punct      = "#d2d4db",
}

local highlights = {
  -- Base UI
  Normal                            = { fg = colors.fg, bg = colors.bg },
  LineNr                            = { fg = colors.line_nr, bg = "NONE" },
  CursorLine                        = { bg = colors.cursorline },
  CursorLineNr                      = { fg = colors.gold, bg = "NONE", bold = true },
  Visual                            = { bg = colors.visual },
  VertSplit                         = { fg = colors.split, bg = "NONE" },
  WinSeparator                      = { fg = colors.split, bg = "NONE" },
  SignColumn                        = { bg = colors.bg },
  StatusLine                        = { fg = colors.fg, bg = colors.status_bg },
  StatusLineNC                      = { fg = colors.line_nr, bg = colors.bg },
  Pmenu                             = { fg = colors.fg, bg = colors.status_bg },
  PmenuSel                          = { fg = "#ffffff", bg = colors.visual },

  -- Standard Vim Syntax
  Comment                           = { fg = colors.grey_dark, italic = true },
  String                            = { fg = colors.green },
  Number                            = { fg = colors.blue },
  Float                             = { fg = colors.blue },
  Identifier                        = { fg = colors.grey_light },
  Function                          = { fg = colors.gold },
  Statement                         = { fg = colors.orange },
  Type                              = { fg = colors.yellow },
  Special                           = { fg = colors.yellow },
  PreProc                           = { fg = colors.green_alt },
  Delimiter                         = { fg = colors.punct },

  -- The Targets (Standard)
  Boolean                           = { fg = colors.blue },   -- True, False
  Constant                          = { fg = colors.blue },   -- None
  Operator                          = { fg = colors.orange }, -- =, +, -
  Keyword                           = { fg = colors.orange },
  Include                           = { fg = colors.yellow }, -- import, from

  -- TreeSitter Basics
  ["@variable"]                     = { fg = colors.grey_light },
  ["@variable.builtin"]             = { fg = colors.gold },
  ["@module"]                       = { fg = colors.grey_light },
  ["@type"]                         = { fg = colors.yellow },
  ["@type.builtin"]                 = { fg = colors.gold },
  ["@function"]                     = { fg = colors.gold },
  ["@function.builtin"]             = { fg = colors.gold },
  ["@function.method"]              = { fg = colors.gold },
  ["@keyword"]                      = { fg = colors.orange },
  ["@keyword.return"]               = { fg = colors.orange },
  ["@keyword.operator"]             = { fg = colors.orange },
  ["@string"]                       = { fg = colors.green },
  ["@attribute"]                    = { fg = colors.green_alt },
  ["@punctuation.bracket"]          = { fg = colors.punct },

  -- The Targets (TreeSitter)
  ["@boolean"]                      = { fg = colors.blue },   -- True, False
  ["@constant.builtin"]             = { fg = colors.blue },   -- None
  ["@keyword.import"]               = { fg = colors.yellow }, -- import, from
  ["@operator"]                     = { fg = colors.orange }, -- =, +, -
  ["@punctuation.delimiter"]        = { fg = colors.orange }, -- . (dot)
  ["@punctuation.special"]          = { fg = colors.orange }, -- -> (arrow)

  -- The Targets (LSP Semantic Tokens - THIS FIXES THE OVERRIDE BUG)
  ["@lsp.type.boolean"]             = { fg = colors.blue },   -- True, False
  ["@lsp.typemod.keyword.constant"] = { fg = colors.blue },   -- None (often hijacked here)
  ["@lsp.type.operator"]            = { fg = colors.orange }, -- =, +, -, ., ->
}

-- Apply Highlights
for group, opts in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, opts)
end

-- ==========================================
-- LEGACY PYTHON OVERRIDES
-- ==========================================

-- Break the bad links and force the colors
vim.api.nvim_set_hl(0, "pythonBoolean", { fg = "#649bc4", force = true })
vim.api.nvim_set_hl(0, "pythonNone", { fg = "#649bc4", force = true })

-- Operators and Dots
vim.api.nvim_set_hl(0, "pythonOperator", { fg = "#ff7540", force = true })
vim.api.nvim_set_hl(0, "pythonDot", { fg = "#ff7540", force = true })

-- Imports
vim.api.nvim_set_hl(0, "pythonInclude", { fg = "#ffaa10", force = true })
vim.api.nvim_set_hl(0, "pythonStatement", { fg = "#ff7540", force = true })
