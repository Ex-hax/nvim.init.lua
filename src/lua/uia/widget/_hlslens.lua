require('hlslens').setup({
    -- Suppress hlslens' virtual-text lens (previously set via nvim-scrollbar v1's search handler).
    -- The scrollbar's own search provider shows match positions instead.
    override_lens = function() end,
})
