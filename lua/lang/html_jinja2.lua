require('prettier').setup({
    tab_width = 4,
    use_tabs = true,
    bin = 'prettier', -- Path to Prettier
    filetypes = { 'html', 'jinja' }, -- Add Jinja2 file type
})