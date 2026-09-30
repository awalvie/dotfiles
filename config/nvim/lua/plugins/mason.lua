return {
	"mason-org/mason.nvim",
	opts = {},
	config = function(_, opts)
		require("mason").setup(opts)

		local ensure_installed = {
			-- formatters
			"ruff",
			"prettierd",
			"stylua",
			-- lsp servers
			"ty",
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

		install_if_missing()
	end,
}
