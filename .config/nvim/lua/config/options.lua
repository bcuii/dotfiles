-- ============================================================
-- 必须早于 lazy.nvim 的设置
-- ============================================================
-- nvim-tree 要求：最早期禁用 netrw，否则两者会抢目录 buffer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 24 位真彩色（nvim-tree / devicons 的图标配色需要）
vim.opt.termguicolors = true

-- ============================================================
-- 行号
-- ============================================================
vim.opt.number = true
vim.opt.relativenumber = true -- 相对行号，配合 5j / 3k 这种跳转

-- ============================================================
-- 缩进（全局默认 4 空格，下面按语言覆盖）
-- ============================================================
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Go 官方用 Tab 不用空格，gofmt 会强制改回来，所以这里必须关掉 expandtab
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

-- 这些生态惯例是 2 空格
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "json", "yaml", "toml", "markdown" },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})

-- ============================================================
-- 搜索
-- ============================================================
vim.opt.ignorecase = true -- 默认忽略大小写
vim.opt.smartcase = true  -- 但输入里含大写时又变回区分大小写
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- ============================================================
-- 系统剪贴板：让 y / p 直接和 macOS 剪贴板互通
-- ============================================================
vim.opt.clipboard = "unnamedplus"

-- ============================================================
-- 界面
-- ============================================================
vim.opt.cursorline = true
vim.opt.signcolumn = "yes" -- 符号列常驻，避免诊断出现时整行左右抖动
vim.opt.scrolloff = 8      -- 光标上下至少留 8 行
vim.opt.wrap = false

-- ============================================================
-- 分屏方向
-- Neovim 默认把新分屏开在【左边/上面】，与直觉相反，改掉
-- ============================================================
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ============================================================
-- 文件与响应
-- ============================================================
vim.opt.undofile = true    -- 持久化 undo：关掉文件重新打开仍可撤销
vim.opt.swapfile = false
vim.opt.timeoutlen = 400   -- 组合键等待时间，默认 1000ms 太久
vim.opt.updatetime = 250

-- ============================================================
-- 诊断显示
-- 默认只画 sign 和下划线，消息要按 <C-w>d 才看得到。
-- 打开 virtual_text 让消息常驻行尾，跳转时再自动弹完整浮窗。
-- ============================================================
vim.diagnostic.config({
  -- 只显示 WARN 以上，否则 gopls 的 hint/info 会很吵
  virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
  severity_sort = true, -- 同一行多个诊断时，错误排最前
  jump = {
    -- 用 ]d / [d 跳转时自动弹出该处的完整诊断
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
})
