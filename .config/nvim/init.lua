vim.pack.add({
  "https://github.com/vague-theme/vague.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/tpope/vim-surround",
  "https://github.com/chomosuke/typst-preview.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-cmdline",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saadparwaiz1/cmp_luasnip",
  "https://github.com/chentoast/marks.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
})

vim.g.mapleader = ","
vim.g.maplocalleader = ","

local options = {
  termguicolors = true,
  cursorline    = false,
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
  fileformats   = { "unix", "dos" },
  number        = true,
  signcolumn    = "yes",
  showtabline   = 2,
  colorcolumn   = "80",
  winborder     = "rounded",
  updatetime    = 250,
  swapfile      = false,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

local keymap = vim.keymap.set
local opts = { silent = true }

keymap("n", "<s-l>", ":bnext<cr>", opts)
keymap("n", "<s-h>", ":bprevious<cr>", opts)
keymap("n", "<leader>ev", ":edit $MYVIMRC<cr>")

keymap('n', '<Leader>fg', ":Telescope git_files<cr>", opts)
keymap('n', '<Leader>fr', ":Telescope live_grep<cr>", opts)
keymap('n', '<Leader>ff', ":Telescope find_files<cr>", opts)
keymap('n', '<Leader>fb', ":Telescope buffers<cr>", opts)
keymap('n', '<Leader>fh', ":Telescope find_files hidden=true<cr>", opts)

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = vim.lsp.config
lspconfig("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
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
  capabilities = capabilities,
})

lspconfig("tinymist", {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  capabilities = capabilities,
  settings = {
    formatterMode = "typstyle",
    typstyle = { lineWidth = 80 },
  },
})

lspconfig("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  capabilities = capabilities,
})

vim.lsp.enable({ "clangd", "lua_ls", "tinymist", "basedpyright" })

require("mason").setup({})

local mason_registry = require("mason-registry")

local packages = {
  "lua-language-server",
  "clangd",
  "tinymist",
  "basedpyright"
}

mason_registry.refresh(function()
  for _, pkg_name in ipairs(packages) do
    local pkg = mason_registry.get_package(pkg_name)
    if not pkg:is_installed() then
      print("Installing " .. pkg_name .. "...")
      pkg:install()
    end
  end
end)

require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

require("marks").setup({
  builtin_marks = { "<", ">", "^" },
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

require("nvim-autopairs").setup({ check_ts = true })
local Rule = require("nvim-autopairs.rule")
require("nvim-autopairs").add_rules({
  Rule("$", "$", "typst"),
  Rule("*", "*", "typst"),
})

require("nvim-treesitter").setup({
  ensure_installed = { "c", "lua", "typst", "python" },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = { enable = true },
})

require('telescope').setup({})

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable,
    ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  })
})

cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })

cmp.setup.cmdline(":", { sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    local clients = vim.lsp.get_clients({ bufnr = args.buf })
    if #clients > 0 then
      vim.lsp.buf.format({ bufnr = args.buf, async = false })
    end
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      source = "always",
      prefix = " ",
    })
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
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
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
})
