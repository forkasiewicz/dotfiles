vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/kylechui/nvim-surround",
  "https://github.com/chomosuke/typst-preview.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/morhetz/gruvbox",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
})

vim.g.mapleader      = ","
vim.g.maplocalleader = ","

vim.o.termguicolors  = true
vim.o.completeopt    = "menuone,noselect,popup"
vim.o.expandtab      = true
vim.o.tabstop        = 2
vim.o.softtabstop    = 2
vim.o.shiftwidth     = 2
vim.o.scrolloff      = 8
vim.o.sidescrolloff  = 4
vim.o.clipboard      = "unnamedplus"
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.incsearch      = true
vim.o.hlsearch       = true
vim.o.fileformats    = "unix,dos"
vim.o.number         = true
vim.o.signcolumn     = "yes"
vim.o.colorcolumn    = "80"
vim.o.updatetime     = 250
vim.o.swapfile       = false

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}))
end

map("n", "<s-l>", ":bnext<cr>")
map("n", "<s-h>", ":bprevious<cr>")
map("n", "<leader>ev", ":edit $MYVIMRC<cr>")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

map("x", "p", '"_dP')

for _, ch in ipairs({ "h", "j", "k", "l" }) do
  map("n", "<C-" .. ch .. ">", "<C-w>" .. ch)
  map("t", "<C-" .. ch .. ">", "<C-\\><C-N><C-w>" .. ch)
end

map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<C-Up>", ":resize +1<CR>")
map("n", "<C-Down>", ":resize -1<CR>")
map("n", "<C-Left>", ":vertical resize -1<CR>")
map("n", "<C-Right>", ":vertical resize +1<CR>")

map("n", "<leader>ff", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
map("n", "<leader>fg", "<cmd>lua require('fzf-lua').live_grep()<CR>", { silent = true })
map("n", "<leader>fb", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })

require('blink.cmp').setup({
  keymap = {
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },

    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
  },
  completion = {
    list = {
      selection = {
        preselect = false,
        auto_insert = false,
      },
    },
  },
  sources = {
    default = { 'lsp', 'buffer' },
    providers = { lsp = { fallbacks = { 'buffer' } } },
  },
  cmdline = {
    enabled = true,
    keymap = { preset = 'cmdline' },
    sources = { 'cmdline', 'path', 'buffer' }
  }
})

require("mason").setup({})
local mason_registry = require("mason-registry")
local lspconfig = vim.lsp.config

local servers = {
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    settings = { Lua = { runtime = { version = "LuaJIT" }, diagnostics = { globals = { "vim" } } } }
  },
  clangd = {
    cmd = { "clangd", "--header-insertion=never" },
    filetypes = { "c", "cpp" }
  },
  tinymist = {
    cmd = { "tinymist" },
    filetypes = { "typst" },
    settings = { formatterMode = "typstyle", typstyle = { lineWidth = 80 } }
  },
  basedpyright = {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" }
  },
  svelte = {
    cmd = { "svelteserver", "--stdio" },
    filetypes = { "svelte" }
  },
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
  },
}

mason_registry.refresh(function()
  for name, config in pairs(servers) do
    local pkg_name = name == "ts_ls" and "typescript-language-server" or name == "svelte" and "svelte-language-server" or
        name:gsub("_", "-")
    local ok, pkg = pcall(mason_registry.get_package, pkg_name)
    if ok and not pkg:is_installed() then pkg:install() end

    lspconfig(name, config)
  end
  vim.lsp.enable(vim.tbl_keys(servers))
end)

vim.o.background = "dark"
vim.g.gruvbox_contrast_dark = "hard"
vim.cmd.colorscheme("gruvbox")

require("lualine").setup({
  icons_enabled = false,
  options = {
    section_separators = "",
    component_separators = "",
    theme = "gruvbox-material",
    icons_enabled = false
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
})

require("fzf-lua").setup({ "max-perf" })

require("nvim-surround").setup({})
require("nvim-autopairs").setup({ check_ts = true })
require("nvim-autopairs").add_rules({
  require("nvim-autopairs.rule")("$", "$", "typst"),
  require("nvim-autopairs.rule")("*", "*", "typst"),
})

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
require("nvim-treesitter").setup({
  ensure_installed = { "c", "lua", "typst", "python" },
  highlight = { enable = true },
  indent = { enable = true },
})

vim.diagnostic.config({
  float = { focusable = false, source = "always", prefix = " " }
})

local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("CursorHold", {
  group = group,
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(args)
    if #vim.lsp.get_clients({ bufnr = args.buf }) > 0 then
      vim.lsp.buf.format({ bufnr = args.buf, async = false })
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function() vim.hl.hl_op() end,
})
