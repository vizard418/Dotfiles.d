-- Clipboard
vim.keymap.set("v", "y", '"+y')
vim.keymap.set("v", "Y", '"+y')

-- Mapping
vim.keymap.set('i', '<C-Space>', '<C-n>', { noremap = true, silent = true })

-- Autocompletado basico con la tecla Tab o C-n / C-p
vim.keymap.set('i', '<Tab>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-n>'
    else
        return '<Tab>'
    end
end, { expr = true, silent = true })

vim.keymap.set('i', '<S-Tab>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-p>'
    else
        return '<S-Tab>'
    end
end, { expr = true, silent = true })

-- Salto entre clases y defs usando J (siguiente) y K (anterior)
vim.keymap.set('n', 'J', function()
    local pos = vim.fn.getpos('.')
    vim.fn.cursor(pos[2], pos[3] + 1)
    vim.fn.search('^[[:space:]]*\\(class\\|def\\)[[:space:]]\\+', 'W')
end, { desc = "Siguiente funcion o clase" })

vim.keymap.set('n', 'K', function()
    vim.fn.search('^[[:space:]]*\\(class\\|def\\)[[:space:]]\\+', 'Wb')
end, { desc = "Funcion o clase anterior" })
