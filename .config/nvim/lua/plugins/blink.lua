return {
  {
    "saghen/blink.cmp",
    -- v2 在活跃开发中、有 breaking change，且需额外安装 blink.lib，所以锁 v1 稳定线
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    -- 官方片段不带 event：blink 默认也接管命令行补全，
    -- 按 InsertEnter 懒加载会导致敲 : 时插件尚未载入
    opts = {
      -- default: <C-y> 确认、<C-n>/<C-p> 选择、<C-e> 关闭、<C-space> 开菜单或看文档
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      -- 有预编译二进制就用 Rust 实现，否则退回 Lua 并警告（本机无 Rust 工具链）
      fuzzy = { implementation = "prefer_rust_with_warning" },
      -- blink 默认 signature.enabled = false（v1 里标为实验性）。
      -- 打开后括号内自动弹参数提示，<C-k> 手动开关。
      signature = { enabled = true },
      -- 官方默认 auto_show = false，要按 <C-space> 才出文档窗。
      -- 打开后选中候选项自动弹，<C-f>/<C-b> 翻页。
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 500 } },
    },
    opts_extend = { "sources.default" },
  },
}
