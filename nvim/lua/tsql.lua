-- Detectar extension .tsql como sql
vim.filetype.add({
    extension = {
        tsql = "sql",
    },
})

local editor_win = nil

-- Opciones y comandos especificos para archivos SQL/T-SQL
vim.api.nvim_create_autocmd("FileType", {
    pattern = "sql",
    callback = function()
        vim.bo.commentstring = "-- %s"
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
        vim.bo.expandtab = true

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

            editor_win = vim.api.nvim_get_current_win()

            local cmd = string.format(
                "bash -ic 'SQLCMD_CONNECT -i %s'",
                tmp_file
            )

            vim.cmd("botright split | term " .. cmd)

            vim.defer_fn(function()
                os.remove(tmp_file)

                if vim.bo.buftype == "terminal" then
                    vim.cmd("stopinsert")
                end
            end, 500)

            vim.defer_fn(function()
                if vim.bo.buftype == "terminal" then
                    vim.cmd("stopinsert")
                end
            end, 1000)
        end, {
            range = true,
            desc = "Ejecutar seleccion T-SQL con sqlcmd_connect",
        })
    end,
})

-- Configuracion de ventanas de terminal
vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false

        vim.keymap.set("n", "q", function()
            local terminal_win = vim.api.nvim_get_current_win()

            if vim.api.nvim_win_is_valid(terminal_win) then
                vim.api.nvim_win_close(terminal_win, true)
            end

            if editor_win
                and vim.api.nvim_win_is_valid(editor_win) then
                vim.api.nvim_set_current_win(editor_win)
            end
        end, {
            buffer = true,
            silent = true,
            desc = "Cerrar resultado SQL y volver al editor",
        })

        vim.keymap.set("n", "<Esc>", "<cmd>stopinsert<CR>", {
            buffer = true,
            silent = true,
        })
    end,
})
