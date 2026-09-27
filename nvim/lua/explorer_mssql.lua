local M = {}

local state = {
    buf = nil,
    win = nil,
    nodes = {},
    width = 45,
}

local function sqlcmd(query)
    local tmp_file = os.tmpname()

    local file = io.open(tmp_file, "w")

    if not file then
        vim.notify(
            "No se pudo crear archivo temporal",
            vim.log.levels.ERROR
        )
        return nil
    end

    file:write("SET NOCOUNT ON;\n")
    file:write(query)
    file:write("\n")
    file:close()

    local cmd = string.format(
        "bash -ic 'SQLCMD_CONNECT -h -1 -W -s \"|\" -i %s' 2>/dev/null",
        tmp_file
    )

    local output = vim.fn.system(cmd)

    os.remove(tmp_file)

    if vim.v.shell_error ~= 0 then
        vim.notify(
            "Error ejecutando SQLCMD_CONNECT:\n" .. output,
            vim.log.levels.ERROR
        )
        return nil
    end

    return output
end

local function split_lines(text)
    local result = {}

    for line in text:gmatch("[^\r\n]+") do
        line = vim.trim(line)

        if line ~= "" then
            table.insert(result, line)
        end
    end

    return result
end

local function query_list(query)
    local output = sqlcmd(query)

    if not output then
        return {}
    end

    return split_lines(output)
end

local function query_columns(query)
    local output = sqlcmd(query)

    if not output then
        return {}
    end

    local result = {}

    for line in output:gmatch("[^\r\n]+") do
        line = vim.trim(line)

        if line ~= "" then
            local parts = {}

            for part in line:gmatch("[^|]+") do
                table.insert(parts, vim.trim(part))
            end

            if #parts >= 3 then
                table.insert(result, {
                    name = parts[1],
                    type = parts[2],
                    nullable = parts[3],
                })
            end
        end
    end

    return result
end

local function escape_identifier(value)
    return value:gsub("]", "]]")
end

local function current_node()
    if not state.buf
        or not vim.api.nvim_buf_is_valid(state.buf)
        or not state.win
        or not vim.api.nvim_win_is_valid(state.win) then
        return nil
    end

    local row = vim.api.nvim_win_get_cursor(state.win)[1]

    return state.nodes[row]
end

local function node_icon(node)
    if node.type == "root" then
        return ""
    end

    if node.type == "database"
        or node.type == "category"
        or node.type == "table" then

        if node.expanded then
            return "▾"
        end

        return "▸"
    end

    return "·"
end

local function has_next_sibling(index, depth)
    for i = index + 1, #state.nodes do
        if state.nodes[i].depth < depth then
            return false
        end

        if state.nodes[i].depth == depth then
            return true
        end
    end

    return false
end

local function tree_prefix(index, node)
    if node.depth == 0 then
        return ""
    end

    local ancestors = {}

    for depth = 1, node.depth - 1 do
        for i = index - 1, 1, -1 do
            if state.nodes[i].depth == depth then
                ancestors[depth] = i
                break
            end
        end
    end

    local prefix = ""

    for depth = 1, node.depth - 1 do
        local ancestor = ancestors[depth]

        if ancestor and has_next_sibling(ancestor, depth) then
            prefix = prefix .. "│  "
        else
            prefix = prefix .. "   "
        end
    end

    if has_next_sibling(index, node.depth) then
        prefix = prefix .. "├─ "
    else
        prefix = prefix .. "└─ "
    end

    return prefix
end

local function node_text(index, node)
    if node.type == "root" then
        return node.name
    end

    local prefix = tree_prefix(index, node)
    local icon = node_icon(node)

    if node.type == "column" then
        return string.format(
            "%s%s %s : %s%s",
            prefix,
            icon,
            node.name,
            node.data_type or "",
            node.nullable == "YES" and " ?" or ""
        )
    end

    return string.format(
        "%s%s %s",
        prefix,
        icon,
        node.name
    )
end

local function render()
    if not state.buf
        or not vim.api.nvim_buf_is_valid(state.buf) then
        return
    end

    local lines = {}

    for index, node in ipairs(state.nodes) do
        table.insert(lines, node_text(index, node))
    end

    vim.bo[state.buf].modifiable = true

    vim.api.nvim_buf_set_lines(
        state.buf,
        0,
        -1,
        false,
        lines
    )

    vim.bo[state.buf].modifiable = false
end

local function database_nodes()
    local databases = query_list([[
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE'
ORDER BY name
]])

    local result = {}

    for _, database in ipairs(databases) do
        table.insert(result, {
            type = "database",
            name = database,
            depth = 1,
            expanded = false,
            database = database,
        })
    end

    return result
end

local function category_nodes(database)
    return {
        {
            type = "category",
            name = "Tables",
            depth = 2,
            expanded = false,
            category = "tables",
            database = database,
        },
        {
            type = "category",
            name = "Views",
            depth = 2,
            expanded = false,
            category = "views",
            database = database,
        },
        {
            type = "category",
            name = "Stored Procedures",
            depth = 2,
            expanded = false,
            category = "procedures",
            database = database,
        },
        {
            type = "category",
            name = "Functions",
            depth = 2,
            expanded = false,
            category = "functions",
            database = database,
        },
    }
end

local function object_nodes(node)
    local database = escape_identifier(node.database)

    local queries = {
        tables = string.format([[
SELECT
    s.name + '.' + t.name
FROM [%s].sys.tables t
INNER JOIN [%s].sys.schemas s
    ON s.schema_id = t.schema_id
ORDER BY
    s.name,
    t.name
]], database, database),

        views = string.format([[
SELECT
    s.name + '.' + v.name
FROM [%s].sys.views v
INNER JOIN [%s].sys.schemas s
    ON s.schema_id = v.schema_id
ORDER BY
    s.name,
    v.name
]], database, database),

        procedures = string.format([[
SELECT
    s.name + '.' + p.name
FROM [%s].sys.procedures p
INNER JOIN [%s].sys.schemas s
    ON s.schema_id = p.schema_id
ORDER BY
    s.name,
    p.name
]], database, database),

        functions = string.format([[
SELECT
    s.name + '.' + o.name
FROM [%s].sys.objects o
INNER JOIN [%s].sys.schemas s
    ON s.schema_id = o.schema_id
WHERE o.type IN ('FN', 'IF', 'TF')
ORDER BY
    s.name,
    o.name
]], database, database),
    }

    local objects = query_list(queries[node.category])
    local result = {}

    for _, object_name in ipairs(objects) do
        local object_type = "object"

        if node.category == "tables" then
            object_type = "table"
        end

        table.insert(result, {
            type = object_type,
            name = object_name,
            depth = 3,
            expanded = false,
            database = node.database,
            category = node.category,
            object = object_name,
        })
    end

    return result
end

local function table_columns(node)
    local schema, table_name = node.object:match("^([^%.]+)%.(.+)$")

    if not schema or not table_name then
        return {}
    end

    local database = escape_identifier(node.database)
    local escaped_schema = schema:gsub("'", "''")
    local escaped_table = table_name:gsub("'", "''")

    local query = string.format([[
SELECT
    c.name,
    ty.name,
    CASE
        WHEN c.is_nullable = 1 THEN 'YES'
        ELSE 'NO'
    END
FROM [%s].sys.columns c
INNER JOIN [%s].sys.tables t
    ON t.object_id = c.object_id
INNER JOIN [%s].sys.schemas s
    ON s.schema_id = t.schema_id
INNER JOIN [%s].sys.types ty
    ON ty.user_type_id = c.user_type_id
WHERE s.name = '%s'
AND t.name = '%s'
ORDER BY c.column_id
]],
        database,
        database,
        database,
        database,
        escaped_schema,
        escaped_table
    )

    local columns = query_columns(query)
    local result = {}

    for _, column in ipairs(columns) do
        table.insert(result, {
            type = "column",
            name = column.name,
            data_type = column.type,
            nullable = column.nullable,
            depth = 4,
            database = node.database,
            object = node.object,
        })
    end

    return result
end

local function remove_children(index, depth)
    local i = index + 1

    while i <= #state.nodes do
        if state.nodes[i].depth <= depth then
            break
        end

        table.remove(state.nodes, i)
    end
end

local function insert_after(index, nodes)
    for i = #nodes, 1, -1 do
        table.insert(
            state.nodes,
            index + 1,
            nodes[i]
        )
    end
end

local function toggle_node(node)
    if not node then
        return
    end

    local row = vim.api.nvim_win_get_cursor(state.win)[1]

    if node.type == "root" then
        return
    end

    if node.expanded then
        node.expanded = false

        remove_children(row, node.depth)
        render()

        vim.api.nvim_win_set_cursor(
            state.win,
            { row, 0 }
        )

        return
    end

    local children = {}

    if node.type == "database" then
        children = category_nodes(node.database)

    elseif node.type == "category" then
        children = object_nodes(node)

    elseif node.type == "table" then
        children = table_columns(node)

    else
        return
    end

    node.expanded = true

    insert_after(row, children)
    render()

    vim.api.nvim_win_set_cursor(
        state.win,
        { row, 0 }
    )
end

local function open_editor()
    if not state.win
        or not vim.api.nvim_win_is_valid(state.win) then
        return nil
    end

    vim.api.nvim_set_current_win(state.win)

    vim.cmd("wincmd l")

    return vim.api.nvim_get_current_win()
end

local function open_table(node)
    local schema, table_name = node.object:match("^([^%.]+)%.(.+)$")

    if not schema or not table_name then
        return
    end

    local editor_win = open_editor()

    if not editor_win then
        return
    end

    vim.cmd("enew")

    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].filetype = "sql"

    local query = string.format(
        "USE [%s];\nSELECT TOP 100 *\nFROM [%s].[%s];",
        node.database,
        schema,
        table_name
    )

    vim.api.nvim_buf_set_lines(
        buf,
        0,
        -1,
        false,
        vim.split(query, "\n")
    )
end

local function open_definition(node)
    local editor_win = open_editor()

    if not editor_win then
        return
    end

    vim.cmd("enew")

    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].filetype = "sql"

    local query = string.format(
        "USE [%s];\nEXEC sp_helptext N'%s';",
        node.database,
        node.object
    )

    vim.api.nvim_buf_set_lines(
        buf,
        0,
        -1,
        false,
        vim.split(query, "\n")
    )
end

local function open_node()
    local node = current_node()

    if not node then
        return
    end

    if node.type == "table" then
        open_table(node)

    elseif node.type == "object" then
        open_definition(node)
    end
end

local function refresh()
    local cursor = { 1, 0 }

    if state.win
        and vim.api.nvim_win_is_valid(state.win) then
        cursor = vim.api.nvim_win_get_cursor(state.win)
    end

    state.nodes = {
        {
            type = "root",
            name = "SQL Server",
            depth = 0,
            expanded = true,
        },
        {
            type = "category",
            name = "Databases",
            depth = 1,
            expanded = true,
        },
    }

    local databases = database_nodes()

    for _, node in ipairs(databases) do
        table.insert(
            state.nodes,
            node
        )
    end

    render()

    local row = math.min(
        cursor[1],
        #state.nodes
    )

    vim.api.nvim_win_set_cursor(
        state.win,
        { row, 0 }
    )
end

local function resize_panel(delta)
    if not state.win
        or not vim.api.nvim_win_is_valid(state.win) then
        return
    end

    local current = vim.api.nvim_win_get_width(state.win)
    local new_width = math.max(20, current + delta)

    vim.api.nvim_win_set_width(
        state.win,
        new_width
    )

    state.width = new_width
end

local function show_help()
    vim.notify(
        table.concat({
            "ExploreMSSQL",
            "",
            "<CR>  Expandir / contraer",
            "o     Abrir objeto",
            "r     Refrescar",
            "q     Ocultar panel",
            ">     Agrandar panel",
            "<     Achicar panel",
            "C-l   Ir al editor",
            "C-h   Ir al explorer",
            "g?    Ayuda",
        }, "\n"),
        vim.log.levels.INFO
    )
end

local function close()
    if not state.win
        or not vim.api.nvim_win_is_valid(state.win) then
        return
    end

    vim.api.nvim_win_close(
        state.win,
        false
    )

    state.win = nil
end

local function setup_buffer()
    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].bufhidden = "hide"
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].modifiable = false
    vim.bo[state.buf].filetype = "mssql_explorer"

    vim.keymap.set("n", "<CR>", function()
        toggle_node(current_node())
    end, {
        buffer = state.buf,
        silent = true,
    })

    vim.keymap.set("n", "o", function()
        open_node()
    end, {
        buffer = state.buf,
        silent = true,
    })

    vim.keymap.set("n", "r", function()
        refresh()
    end, {
        buffer = state.buf,
        silent = true,
    })

    vim.keymap.set("n", "q", function()
        close()
    end, {
        buffer = state.buf,
        silent = true,
    })

    vim.keymap.set("n", ">", function()
        resize_panel(5)
    end, {
        buffer = state.buf,
        silent = true,
    })

    vim.keymap.set("n", "<", function()
        resize_panel(-5)
    end, {
        buffer = state.buf,
        silent = true,
    })

    vim.keymap.set("n", "g?", function()
        show_help()
    end, {
        buffer = state.buf,
        silent = true,
    })

    vim.keymap.set("n", "<C-l>", "<C-w>l", {
        buffer = state.buf,
        silent = true,
    })
end

local function create_panel()
    vim.cmd("topleft " .. state.width .. "vnew")

    state.win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(
        state.win,
        state.buf
    )

    vim.wo[state.win].winfixwidth = false
end

local function open()
    if state.win
        and vim.api.nvim_win_is_valid(state.win) then

        vim.api.nvim_set_current_win(state.win)

        return
    end

    if not state.buf
        or not vim.api.nvim_buf_is_valid(state.buf) then

        state.buf = vim.api.nvim_create_buf(false, true)

        setup_buffer()

        state.nodes = {
            {
                type = "root",
                name = "SQL Server",
                depth = 0,
                expanded = true,
            },
            {
                type = "category",
                name = "Databases",
                depth = 1,
                expanded = true,
            },
        }
    end

    create_panel()

    refresh()
end

vim.keymap.set("n", "<C-h>", function()
    if state.win
        and vim.api.nvim_win_is_valid(state.win) then

        vim.api.nvim_set_current_win(state.win)
    end
end, {
    silent = true,
    desc = "Ir al explorer MSSQL",
})

vim.api.nvim_create_user_command(
    "ExploreMSSQL",
    function()
        open()
    end,
    {
        desc = "Abrir explorador MSSQL",
    }
)

M.open = open

return M
