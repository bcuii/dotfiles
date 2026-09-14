return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic", -- 面板贴屏幕下方
      delay = 200,        -- 首次弹出的等待毫秒数；下钻时无延迟

      icons = {
        -- 没装 Nerd Font，关掉图标，否则每行前面都是方块
        mappings = false,
        -- 特殊键名也全是 Nerd Font 私有区字符，换成纯文本
        keys = {
          Up = "Up",
          Down = "Down",
          Left = "Left",
          Right = "Right",
          C = "C-",
          M = "M-",
          D = "D-",
          S = "S-",
          CR = "CR",
          Esc = "ESC",
          NL = "NL",
          BS = "BS",
          Space = "SPC",
          Tab = "TAB",
          ScrollWheelDown = "ScrollDown",
          ScrollWheelUp = "ScrollUp",
          F1 = "F1",
          F2 = "F2",
          F3 = "F3",
          F4 = "F4",
          F5 = "F5",
          F6 = "F6",
          F7 = "F7",
          F8 = "F8",
          F9 = "F9",
          F10 = "F10",
          F11 = "F11",
          F12 = "F12",
        },
      },

      -- 给前缀起名。这不创建键位，只影响面板显示
      spec = {
        { "<leader>s", group = "分屏" },
        { "<leader>c", group = "代码" },
        { "<leader>f", group = "查找" },
      },
    },
  },
}
