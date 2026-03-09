-- mason.lua
require("mason").setup()

-- Auto-update all installed Mason packages in the background on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local registry = require("mason-registry")
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
