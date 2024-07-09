local configs = require "nvchad.configs.lspconfig"

local servers = {
  html = {},
  cssls = {},
  ruff_lsp = {},
  -- emmet_ls = {},
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
