local M = {}

local state = {
    buf = nil,
    win = nil,
    nodes = {},
    width = 45,
    root_path = vim.uv.cwd(),
}

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
    if node.type == "root"
        or node.type == "files_header"
        or node.type == "buffers_header"
        or node.type == "empty" then
        return ""
    end

    if node.type == "directory" then
        if node.expanded then
            return "▾"
        end
        return "▸"
    end

    if node.type == "open_buffer" then
        return "▪"
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
    if node.depth == 0
        or node.type == "files_header"
        or node.type == "buffers_header"
        or node.type == "empty" then
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

    if node.type == "files_header" then
        return "--- Files ---"
    end

    if node.type == "buffers_header" then
        return "--- Buffers ---"
    end

    if node.type == "empty" then
        return ""
    end

    if node.type == "open_buffer" then
        local active_marker = node.is_current and "* " or "  "
        return string.format("  %s%s", active_marker, node.name)
    end

    local prefix = tree_prefix(index, node)
    local icon = node_icon(node)

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

local function read_directory(path, depth)
    local handle = vim.uv.fs_scandir(path)

    if not handle then
        return {}
    end

    local dirs = {}
    local files = {}

    while true do
        local name, t = vim.uv.fs_scandir_next(handle)

        if not name then
            break
        end

        if name ~= "." and name ~= ".." and name ~= ".git" then
            local full_path = path .. "/" .. name

            if t == "directory" or t == "link" then
                table.insert(dirs, {
                    type = "directory",
                    name = name,
                    path = full_path,
                    depth = depth,
                    expanded = false,
                })
            else
                table.insert(files, {
                    type = "file",
                    name = name,
                    path = full_path,
                    depth = depth,
                })
            end
        end
    end

    table.sort(dirs, function(a, b)
        return a.name < b.name
    end)

    table.sort(files, function(a, b)
        return a.name < b.name
    end)

    local result = {}

    for _, d in ipairs(dirs) do
        table.insert(result, d)
    end

    for _, f in ipairs(files) do
        table.insert(result, f)
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

local function open_editor()
    if not state.win
        or not vim.api.nvim_win_is_valid(state.win) then
        return nil
    end

    vim.api.nvim_set_current_win(state.win)
    vim.cmd("wincmd l")

    return vim.api.nvim_get_current_win()
end

local function open_file(node)
    local editor_win = open_editor()

    if not editor_win then
        return
    end

    local target_path = vim.fn.fnamemodify(node.path, ":p")
    local existing_buf = nil

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if vim.fn.fnamemodify(buf_name, ":p") == target_path then
                existing_buf = buf
                break
            end
        end
    end

    if existing_buf then
        vim.api.nvim_set_current_buf(existing_buf)
    else
        vim.cmd("edit " .. vim.fn.fnameescape(node.path))
    end
end

local function switch_to_buffer(node)
    local editor_win = open_editor()

    if not editor_win then
        return
    end

    if vim.api.nvim_buf_is_valid(node.bufnr) then
        vim.api.nvim_set_current_buf(node.bufnr)
    end
end

local function toggle_node(node)
    if not node then
        return
    end

    local row = vim.api.nvim_win_get_cursor(state.win)[1]

    if node.type == "root"
        or node.type == "files_header"
        or node.type == "buffers_header"
        or node.type == "empty" then
        return
    end

    if node.type == "open_buffer" then
        switch_to_buffer(node)
        return
    end

    if node.type == "file" then
        open_file(node)
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

    local children = read_directory(
        node.path,
        node.depth + 1
    )

    node.expanded = true

    insert_after(row, children)
    render()

    vim.api.nvim_win_set_cursor(
        state.win,
        { row, 0 }
    )
end

local function open_node()
    local node = current_node()

    if not node then
        return
    end

    if node.type == "file" then
        open_file(node)
    elseif node.type == "open_buffer" then
        switch_to_buffer(node)
    end
end

local function node_key(node)
    if node.type == "root"
        or node.type == "files_header"
        or node.type == "buffers_header"
        or node.type == "empty" then
        return node.type
    end

    if node.type == "open_buffer" then
        return "buf:" .. node.bufnr
    end

    return node.type .. ":" .. node.path
end

local function save_expanded_state()
    local expanded = {}

    for _, node in ipairs(state.nodes) do
        if node.expanded then
            local key = node_key(node)

            if key then
                expanded[key] = true
            end
        end
    end

    return expanded
end

local function get_open_buffers_nodes()
    local nodes = {
        {
            type = "empty",
            depth = 0,
        },
        {
            type = "buffers_header",
            name = "Buffers",
            depth = 0,
            expanded = true,
        }
    }

    local current_buf = vim.api.nvim_get_current_buf()

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" then
                local display_name = vim.fn.fnamemodify(name, ":t")
                table.insert(nodes, {
                    type = "open_buffer",
                    name = display_name,
                    bufnr = buf,
                    depth = 1,
                    is_current = (buf == current_buf),
                })
            end
        end
    end

    return nodes
end

local function build_tree(expanded)
    local root_name = vim.fn.fnamemodify(
        state.root_path,
        ":t"
    )

    local nodes = {
        {
            type = "files_header",
            name = "Files",
            depth = 0,
            expanded = true,
        },
        {
            type = "root",
            name = root_name ~= ""
                and root_name
                or state.root_path,
            path = state.root_path,
            depth = 0,
            expanded = true,
        },
    }

    local children = read_directory(
        state.root_path,
        1
    )

    for _, child in ipairs(children) do
        local child_key = node_key(child)

        child.expanded = expanded[child_key] == true

        table.insert(nodes, child)

        if child.expanded and child.type == "directory" then
            local sub_children = read_directory(
                child.path,
                child.depth + 1
            )

            for _, sub in ipairs(sub_children) do
                table.insert(nodes, sub)
            end
        end
    end

    local buffer_nodes = get_open_buffers_nodes()
    for _, b_node in ipairs(buffer_nodes) do
        table.insert(nodes, b_node)
    end

    return nodes
end

local function refresh()
    local cursor = { 1, 0 }

    if state.win
        and vim.api.nvim_win_is_valid(state.win) then
        cursor = vim.api.nvim_win_get_cursor(state.win)
    end

    local expanded = save_expanded_state()

    state.nodes = build_tree(expanded)

    render()

    if state.win and vim.api.nvim_win_is_valid(state.win) then
        local row = math.min(
            cursor[1],
            #state.nodes
        )

        vim.api.nvim_win_set_cursor(
            state.win,
            { row, 0 }
        )
    end
end

local function resize_panel(delta)
    if not state.win
        or not vim.api.nvim_win_is_valid(state.win) then
        return
    end

    local current = vim.api.nvim_win_get_width(
        state.win
    )
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
            "ExploreFiles",
            "",
            "<CR>  Expandir / contraer / abrir buffer",
            "o     Abrir archivo / buffer",
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
    vim.api.nvim_buf_set_name(
        state.buf,
        "ExploreFiles"
    )

    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].bufhidden = "hide"
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].modifiable = false
    vim.bo[state.buf].filetype = "files_explorer"

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
    vim.cmd("topleft " .. state.width .. "vsplit")

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

    local first_open = false

    if not state.buf
        or not vim.api.nvim_buf_is_valid(state.buf) then

        state.buf = vim.api.nvim_create_buf(
            false,
            true
        )

        setup_buffer()

        state.nodes = {
            {
                type = "files_header",
                name = "Files",
                depth = 0,
                expanded = true,
            },
            {
                type = "root",
                name = vim.fn.fnamemodify(
                    state.root_path,
                    ":t"
                ),
                path = state.root_path,
                depth = 0,
                expanded = true,
            },
        }

        first_open = true
    end

    create_panel()

    if first_open then
        refresh()
    else
        render()
    end
end

local augroup = vim.api.nvim_create_augroup(
    "ExplorerFilesBuffers",
    { clear = true }
)

vim.api.nvim_create_autocmd(
    { "BufEnter", "BufAdd", "BufDelete", "BufWipeout" },
    {
        group = augroup,
        callback = function()
            if state.win
                and vim.api.nvim_win_is_valid(state.win) then
                refresh()
            end
        end,
    }
)

vim.keymap.set("n", "<C-h>", function()
    if state.win
        and vim.api.nvim_win_is_valid(state.win) then

        vim.api.nvim_set_current_win(state.win)
    end
end, {
    silent = true,
    desc = "Ir al explorer Files",
})

vim.api.nvim_create_user_command(
    "ExploreFiles",
    function()
        open()
    end,
    {
        desc = "Abrir explorador de archivos",
    }
)

M.open = open

return M
