-- Detectar extension .tsql como sql
vim.filetype.add({
    extension = {
        tsql = "sql",
    },
})

-- Opciones y comandos especificos para archivos SQL/T-SQL
vim.api.nvim_create_autocmd("FileType", {
    pattern = "sql",
    callback = function()
        vim.bo.commentstring = "-- %s"
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
        vim.bo.expandtab = true

        -- Crear comando :XSQL para ejecutar el rango seleccionado usando el alias
        vim.api.nvim_buf_create_user_command(0, "SQLCMD", function(opts)
            local lines = vim.fn.getline(opts.line1, opts.line2)
            local query = table.concat(lines, "\n")

            local tmp_file = os.tmpname()
            local f = io.open(tmp_file, "w")
            if f then
                f:write(query)
                f:close()
            else
                print("Error: No se pudo crear archivo temporal")
                return
            end

            local cmd = string.format("bash -ic 'SQLCMD_CONNECT -i %s'", tmp_file)
            vim.cmd("botright split | term " .. cmd)

            -- Configurar para que al salir de la terminal se cierre la ventana automaticamente si termino con exito
            vim.cmd("startinsert")

            vim.defer_fn(function()
                os.remove(tmp_file)
            end, 5000)
        end, { range = true, desc = "Ejecutar seleccion T-SQL con sqlcmd_connect" })
    end,
})

-- Autocomando global para cerrar facilmente las ventanas de terminal con 'q'
vim.api.nvim_create_autocmd("FileType", {
    pattern = "term",
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
    end,
})
