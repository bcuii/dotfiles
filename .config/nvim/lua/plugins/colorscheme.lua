-- 四个配色方案全装上，方便用 :colorscheme <名字> 实时切换。
-- 选定后把下面 tokyonight 的 config 里那一行改成你要的即可。
--
-- 可用名字：
--   tokyonight-night / tokyonight-storm / tokyonight-moon / tokyonight-day
--   catppuccin-mocha / catppuccin-macchiato / catppuccin-frappe / catppuccin-latte
--   gruvbox                     （配 vim.o.background = "dark" / "light"）
--   kanagawa-wave / kanagawa-dragon / kanagawa-lotus
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- 配色要在其他插件之前加载
    config = function()
      vim.cmd.colorscheme("tokyonight-night") -- ← 改这里换默认配色
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
}
