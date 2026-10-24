local mason = require("mason")

local mason_opts = {ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }}

-- Load mason opts from lua/local/mason.lua for overrides - if not present then just load mason with default opts
if #vim.api.nvim_get_runtime_file("lua/local/mason.lua", false) > 0 then
  mason_opts = require("local.mason")
  assert(type(mason_opts) == "table", "local.mason must return an options table")
end

mason.setup(mason_opts)

-- Install LSP through the mason-lspconfig plugin
require("mason-lspconfig").setup({
  automatic_enable = false,
  -- lspconfig server names only; other tools are installed above.
  ensure_installed = {
    -- lua
    "lua_ls",
    "stylua",

    -- rust
    "rust_analyzer",

    -- go
    "gopls",

    -- java
    "jdtls",

    -- python
    "ruff",
    "ty",

    -- plain files
    "helm_ls",
    "yamlls",
    "tombi",
    "marksman",
  },
})


-- Install mason packages that aren't LSP
local tools = {
  "golangci-lint",
  "goimports",
  "java-debug-adapter",
  "java-test",
  "kdlfmt",
  "xmlformatter",
  "shellcheck",
}

local registry = require("mason-registry")

registry.refresh(function(success)
  if not success then
    vim.notify("Failed to refresh Mason registry", vim.log.levels.ERROR)
    return
  end

  for _, name in ipairs(tools) do
    local package = registry.get_package(name)
    if not package:is_installed() and not package:is_installing() then
      package:install()
    end
  end
end)

