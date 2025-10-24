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