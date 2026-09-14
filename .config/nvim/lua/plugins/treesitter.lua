return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- main 分支不支持 lazy-loading，必须在启动时加载
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "lua",
        "vim",
        "vimdoc",
        "query",
        "bash",
        "json",
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
        -- Go
        "go",
        "gomod",
        "gosum",
        "gowork",
        "gotmpl",
        -- Python
        "python",
      })

      -- main 分支不会自动开启高亮，需要手动启动。
      -- 只对已安装 parser 的文件类型启动，未安装的静默跳过。
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          -- language.add() 在 parser 缺失时返回 nil（不抛异常），据此判断
          if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
          end
        end,
      })
    end,
  },
}
