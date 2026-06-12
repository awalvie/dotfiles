STYLUA := stylua
LUA_FILES := $(shell find config/nvim -name "*.lua")

.PHONY: fmt
fmt: ## Format all Lua files with stylua
	@$(STYLUA) $(LUA_FILES)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'
