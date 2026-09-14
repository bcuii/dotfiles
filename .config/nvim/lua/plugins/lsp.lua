return {
  {
    "neovim/nvim-lspconfig",
    -- lspconfig 只提供 lsp/*.lua 配置数据，必须在 runtimepath 上
    -- 才能被 vim.lsp.enable() 找到，所以不要 lazy-load。
    lazy = false,
    config = function()
      -- 让 lua_ls 认识 vim 全局变量和 Neovim 运行时（编辑 nvim 配置时必需）。
      -- 仅在没有项目级 .luarc.json 时生效。
      vim.lsp.config("lua_ls", {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath("config")
              and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
              return
            end
          end
          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
            runtime = {
              version = "LuaJIT",
              path = { "lua/?.lua", "lua/?/init.lua" },
            },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME },
            },
          })
        end,
        settings = { Lua = {} },
      })

      -- 启用的 server。名字对应 lspconfig 的 lsp/<name>.lua
      vim.lsp.enable({ "lua_ls", "clangd", "gopls", "basedpyright" })

      -- Neovim 0.11+ 已内置 grn/gra/grr/gri/grt/gO/K，这里只补缺的
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
    end,
  },
}
