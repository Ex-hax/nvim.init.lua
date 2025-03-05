local session = {}

function session.save()
	vim.cmd('mksession! ~/session.nvim')
	vim.cmd("echomsg '✅ Session has been saved.'")
end

function session.load()
	if vim.fn.filereadable('~/session.nvim') == 1 then
		vim.cmd('source ~/session.nvim')
	else
		vim.cmd("echomsg '❌ Session.nvim not found! please run `mksession! ~/session.vim`'")
	end
end

return session
