return {
  {
    "nvim-tree/nvim-tree.lua",
    -- nvim-web-devicons 提供文件图标（需要 Nerd Font 字体才能正常显示）
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      require("nvim-tree").setup({
        view = { width = 32 },
        renderer = {
          group_empty = true,   -- 把只有一个子目录的空目录合并成一行
        },
        filters = {
          dotfiles = false,     -- 显示 .luarc.json 这类点文件
        },
        update_focused_file = {
          enable = true,        -- 光标所在文件在树里自动高亮
        },
      })

      vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "切换文件树" })
      vim.keymap.set("n", "<leader>o", "<Cmd>NvimTreeFocus<CR>", { desc = "跳到文件树" })
    end,
  },
}
