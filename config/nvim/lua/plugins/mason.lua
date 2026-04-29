return {
  'mason-org/mason.nvim',
  opts = {},
  config = function(_, opts)
    require("mason").setup(opts)

    local ensure_installed = {
      -- formatters
      "ruff",
      "prettierd",
      "stylua",
      -- lsp servers
      "gopls",
      "rust-analyzer",
      "clangd",
      "yaml-language-server",
      "terraform-ls",
      "lua-language-server",
      "html-lsp",
      "bash-language-server",
      "ansible-language-server",
    }

    local function install_if_missing()
      local ok, registry = pcall(require, "mason-registry")
      if not ok then
        return
      end

      registry.refresh(function()
        for _, name in ipairs(ensure_installed) do
          local pkg_ok, pkg = pcall(registry.get_package, name)
          if pkg_ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end

    -- Auto-update all installed Mason packages in the background on startup
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local ok, registry = pcall(require, "mason-registry")
        if not ok then
          return
        end

        registry.refresh(function()
          for _, pkg in ipairs(registry.get_installed_packages()) do
            local installed = pkg:get_installed_version()
            local latest = pkg:get_latest_version()
            if installed ~= latest then
              pkg:install()
            end
          end
        end)
      end,
    })

    install_if_missing()
  end,
}
