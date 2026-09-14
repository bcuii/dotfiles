return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- 原生 fzf 排序算法，大仓库下明显更快。需要 make + C 编译器
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "查找文件" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "全项目搜索内容" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "已打开的 buffer" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "最近打开过的文件" },
      { "<leader>fw", "<Cmd>Telescope grep_string<CR>", desc = "搜索光标下的词" },
      { "<leader>fd", "<Cmd>Telescope diagnostics<CR>", desc = "全部诊断" },
      { "<leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", desc = "当前文件符号" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "帮助文档" },
      { "<leader>f/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "当前文件内搜索" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          -- 结果在左、预览在右
          layout_strategy = "horizontal",
          layout_config = { horizontal = { preview_width = 0.55 }, width = 0.9, height = 0.85 },
          -- 搜索时忽略这些
          file_ignore_patterns = { "%.git/", "node_modules/", "%.o$", "%.so$" },
          path_display = { "truncate" },
        },
        pickers = {
          find_files = { hidden = true }, -- 显示点文件
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
