vim.g.mapleader = ","
vim.g.maplocalleader = ","

local options = {
  termguicolors = true,
  cursorline    = true,
  completeopt   = { "menuone", "noselect" },
  expandtab     = true,
  tabstop       = 2,
  softtabstop   = 2,
  shiftwidth    = 2,
  scrolloff     = 8,
  sidescrolloff = 4,
  clipboard     = "unnamedplus",
  ignorecase    = true,
  smartcase     = true,
  incsearch     = true,
  hlsearch      = true,
}
for k, v in pairs(options) do
  vim.opt[k] = v
end

local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<s-l>", ":bnext<cr>", opts)
keymap("n", "<s-h>", ":bprevious<cr>", opts)
keymap("n", "<leader>ev", "<cmd>edit $MYVIMRC<cr>")

vim.pack.add({
  "https://github.com/vague-theme/vague.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/tpop/vim-surround",
  "https://github.com/chomosuke/typst-preview.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-cmdline",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/vim-vsnip",
})

require("vague").setup({ italic = false })
vim.cmd.colorscheme("vague")

require("lualine").setup({
  options = {
    icons_enabled = false,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
  },
})

local npairs = require("nvim-autopairs")
npairs.setup({ check_ts = true })
local Rule = require("nvim-autopairs.rule")
npairs.add_rules({
  Rule("$", "$", "typst"),
  Rule("*", "*", "typst"),
})

require("nvim-treesitter").setup({
  ensure_installed = { "c", "lua", "typst", "python" },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = { enable = true },
})

local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
  end

  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "K", vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
  map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "clangd", "tinymist", "basedpyright" }
})

local lspconfig = vim.lsp.config
lspconfig("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      signatureHelp = { enabled = true },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    },
  },
})

lspconfig("clangd", {
  cmd = { "clangd", "--header-insertion=never" },
  filetypes = { "c", "cpp", "h", "hpp" },
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig("tinymist", {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    formatterMode = "typstyle",
    typstyle = { lineWidth = 80 },
  },
})

lspconfig("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.enable({ "clangd", "lua_ls", "tinymist", "basedpyright" })

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    vim.lsp.buf.format({ bufnr = args.buf, async = false })
  end,
})

local cmp = require "cmp"
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable,
    ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" },
  }, {
    { name = "buffer" },
  })
})

cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })
cmp.setup.cmdline(":", { sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })
