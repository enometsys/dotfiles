local configs = require "nvchad.configs.lspconfig"

local servers = {
  html = {},
  cssls = {},
  ruff_lsp = {},
  emmet_ls = {},
  rust_analyzer = {},
  volar = {},
  biome = {},
}

for name, opts in pairs(servers) do
  opts.on_init = configs.on_init
  opts.on_attach = configs.on_attach
  opts.capabilities = configs.capabilities

  require("lspconfig")[name].setup(opts)
end

-- Tree-sitter based folding. (Technically not a module because it's per windows and not per buffer.)
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false -- Disable folding at startup
