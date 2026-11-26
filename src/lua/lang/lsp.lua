-- ───────────────────────────────────────────────────────────
-- 💡 LSP Configuration (Language Server Protocol)
-- ───────────────────────────────────────────────────────────
local vim_lsp = vim.lsp
local lsp_server = {
  {serv='pyright', act='enable'}, 
  {serv='ruff', act='enable'},
  {serv='jsonls', act='enable'},
  {serv='html', act='enable'},
  {serv='yamlls', act='enable'},
  {serv='sqlls', act='enable'},
  {serv='lua_ls', act='enable'},
  {serv='vimls', act='enable'}
}

for _, record in ipairs(lsp_server) do
  if record.act == 'enable' then
    vim_lsp.enable(record.serv)
  elseif record.act == 'disable' then
    vim_lsp.disable(record.serv)
  end
end

-- Go to definition (works across files). Ctrl-o = back, Ctrl-i / Tab = forward.
--   gd   go to definition
--   gD   go to declaration
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local o = { buffer = args.buf, silent = true }
    vim.keymap.set('n', 'gd', vim_lsp.buf.definition, vim.tbl_extend('force', o, { desc = 'LSP: go to definition' }))
    vim.keymap.set('n', 'gD', vim_lsp.buf.declaration, vim.tbl_extend('force', o, { desc = 'LSP: go to declaration' }))
  end,
})