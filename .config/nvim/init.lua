vim.pack.add({
  "https://github.com/vague-theme/vague.nvim",
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
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/EdenEast/nightfox.nvim",
  "https://github.com/morhetz/gruvbox",
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
  colorcolumn   = "80",
  -- winborder     = "rounded",
  updatetime    = 250,
  swapfile      = false,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<s-l>", ":bnext<cr>")
map("n", "<s-h>", ":bprevious<cr>")
map("n", "<leader>ev", ":edit $MYVIMRC<cr>")

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("t", "<C-h>", "<C-\\><C-N><C-w>h")
map("t", "<C-j>", "<C-\\><C-N><C-w>j")
map("t", "<C-k>", "<C-\\><C-N><C-w>k")
map("t", "<C-l>", "<C-\\><C-N><C-w>l")

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<C-Up>", ":resize +1<CR>")
map("n", "<C-Down>", ":resize -1<CR>")
map("n", "<C-Left>", ":vertical resize -1<CR>")
map("n", "<C-Right>", ":vertical resize +1<CR>")

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

vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  capabilities = capabilities,
})

lspconfig("svelte", {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  capabilities = capabilities,
  root_dir = function(bufnr)
    return vim.fs.dirname(
      vim.fs.find({ "package.json", ".git" }, { upward = true, path = vim.api.nvim_buf_get_name(bufnr) })[1]
    )
  end,
})

lspconfig("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  capabilities = capabilities,
})

vim.lsp.enable({ "clangd", "lua_ls", "tinymist", "basedpyright", "svelte", "ts_ls" })

require("mason").setup({})

local mason_registry = require("mason-registry")

local packages = {
  "lua-language-server",
  "clangd",
  "tinymist",
  "basedpyright",
  "svelte-language-server",
  "typescript-language-server"
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

-- require("vague").setup({ italic = false })
-- vim.cmd.colorscheme("vague")
-- require('nightfox').setup()
-- vim.cmd.colorscheme("terafox")

vim.o.background = "dark"
vim.g.gruvbox_contrast_dark = "hard"
vim.cmd.colorscheme("gruvbox")

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

-- TODO: fix luasnip
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

-- vim.api.nvim_set_hl(0, "StatusLine", {
--   fg = "foreground",
--   bg = "#606079",
-- })

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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf

    map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
    map("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
    map("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr })
    map("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
    map("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = bufnr })
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = function()
    if require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require("luasnip").session.jump_active then
      require("luasnip").unlink_current()
    end
  end,
})
