return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    opts = {
        pipe_table = {
            cell = "trimmed",
            min_width = 8,
            padding = 1,
        },
    },
    config = function(_, opts)
        require("render-markdown").setup(opts)

        local function trim(s)
            return (s:gsub("^%s+", ""):gsub("%s+$", ""))
        end

        local function split_unescaped_pipes(line)
            local cells = {}
            local current = {}
            local escaped = false

            for i = 1, #line do
                local ch = line:sub(i, i)
                if ch == "|" and not escaped then
                    table.insert(cells, table.concat(current))
                    current = {}
                else
                    table.insert(current, ch)
                end

                escaped = ch == "\\" and not escaped
                if ch ~= "\\" then
                    escaped = false
                end
            end

            table.insert(cells, table.concat(current))
            return cells
        end

        local function parse_row(line)
            local indent = line:match("^%s*") or ""
            local content = line:sub(#indent + 1)
            local has_outer_pipes = content:match("^|.*|%s*$") ~= nil
            local raw_cells = split_unescaped_pipes(content)

            if has_outer_pipes and #raw_cells >= 2 then
                table.remove(raw_cells, 1)
                table.remove(raw_cells, #raw_cells)
            end

            for i, cell in ipairs(raw_cells) do
                raw_cells[i] = trim(cell)
            end

            return {
                indent = indent,
                has_outer_pipes = has_outer_pipes,
                cells = raw_cells,
            }
        end

        local function is_delimiter_cell(cell)
            return cell:match("^:?-+:?$") ~= nil
        end

        local function is_delimiter_row(cells)
            if #cells == 0 then
                return false
            end
            for _, cell in ipairs(cells) do
                if not is_delimiter_cell(trim(cell)) then
                    return false
                end
            end
            return true
        end

        local function split_br(cell)
            local normalized = cell:gsub("<br%s*/?>", "\n")
            local parts = {}
            for part in (normalized .. "\n"):gmatch("(.-)\n") do
                table.insert(parts, trim(part))
            end
            if #parts == 0 then
                table.insert(parts, "")
            end
            return parts
        end

        local function wrap_words(text, max_width)
            local words = {}
            for word in text:gmatch("%S+") do
                table.insert(words, word)
            end

            if #words == 0 then
                return { "" }
            end

            local lines = {}
            local current = ""

            for _, word in ipairs(words) do
                local candidate = current == "" and word or (current .. " " .. word)
                if vim.fn.strdisplaywidth(candidate) <= max_width then
                    current = candidate
                else
                    if current ~= "" then
                        table.insert(lines, current)
                    end
                    current = word
                end
            end

            if current ~= "" then
                table.insert(lines, current)
            end

            return lines
        end

        local function wrap_cell(cell, max_width)
            local parts = split_br(cell)
            local wrapped = {}

            for _, part in ipairs(parts) do
                local lines = wrap_words(part, max_width)
                for _, line in ipairs(lines) do
                    table.insert(wrapped, line)
                end
            end

            return table.concat(wrapped, "<br>")
        end

        local function alignment_from_delimiter(cell)
            local stripped = trim(cell)
            local left = stripped:sub(1, 1) == ":"
            local right = stripped:sub(-1) == ":"
            if left and right then
                return "center"
            elseif right then
                return "right"
            elseif left then
                return "left"
            end
            return "none"
        end

        local function delimiter_for_alignment(alignment, width)
            local w = math.max(3, width)
            local dashes = string.rep("-", w)
            if alignment == "center" then
                if w == 3 then
                    return ":-:"
                end
                return ":" .. dashes:sub(2, w - 1) .. ":"
            elseif alignment == "right" then
                return dashes:sub(1, w - 1) .. ":"
            elseif alignment == "left" then
                return ":" .. dashes:sub(2)
            end
            return dashes
        end

        local function is_table_like(line)
            return line ~= nil and line:find("|", 1, true) ~= nil and trim(line) ~= ""
        end

        local function format_table_range(start_row, end_row, max_width)
            local table_lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
            if vim.bo.filetype ~= "markdown" then
                vim.notify("MarkdownTableSquish works in markdown buffers only", vim.log.levels.WARN)
                return false
            end

            local parsed = {}
            local delimiter_index = nil

            for i = 1, #table_lines do
                local entry = parse_row(table_lines[i])
                table.insert(parsed, entry)
                if delimiter_index == nil and is_delimiter_row(entry.cells) then
                    delimiter_index = #parsed
                end
            end

            if delimiter_index == nil then
                return false
            end

            local column_count = 0
            for _, entry in ipairs(parsed) do
                column_count = math.max(column_count, #entry.cells)
            end

            local alignments = {}
            for i = 1, column_count do
                local cell = parsed[delimiter_index].cells[i] or "---"
                alignments[i] = alignment_from_delimiter(cell)
            end

            for i, entry in ipairs(parsed) do
                if i ~= delimiter_index then
                    for col = 1, column_count do
                        local value = entry.cells[col] or ""
                        entry.cells[col] = wrap_cell(value, max_width)
                    end
                end
            end

            local col_widths = {}
            for col = 1, column_count do
                col_widths[col] = 3
            end

            for i, entry in ipairs(parsed) do
                if i ~= delimiter_index then
                    for col = 1, column_count do
                        local cell = entry.cells[col] or ""
                        for part in (cell .. "<br>"):gmatch("(.-)<br>") do
                            local width = vim.fn.strdisplaywidth(part)
                            if width > col_widths[col] then
                                col_widths[col] = width
                            end
                        end
                    end
                end
            end

            local indent = parsed[1].indent
            local has_outer_pipes = parsed[1].has_outer_pipes

            local function format_normal_row(entry)
                local cells = {}
                for col = 1, column_count do
                    local value = entry.cells[col] or ""
                    local pad = col_widths[col] - vim.fn.strdisplaywidth(value)
                    table.insert(cells, " " .. value .. string.rep(" ", pad) .. " ")
                end
                local joined = table.concat(cells, "|")
                if has_outer_pipes then
                    return indent .. "|" .. joined .. "|"
                end
                return indent .. joined
            end

            local function format_delimiter_row()
                local cells = {}
                for col = 1, column_count do
                    local delim = delimiter_for_alignment(alignments[col], col_widths[col])
                    table.insert(cells, " " .. delim .. " ")
                end
                local joined = table.concat(cells, "|")
                if has_outer_pipes then
                    return indent .. "|" .. joined .. "|"
                end
                return indent .. joined
            end

            local output = {}
            for i, entry in ipairs(parsed) do
                if i == delimiter_index then
                    table.insert(output, format_delimiter_row())
                else
                    table.insert(output, format_normal_row(entry))
                end
            end

            vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, output)
            return true
        end

        local function format_all_markdown_tables(max_width)
            if vim.bo.filetype ~= "markdown" then
                vim.notify("MarkdownTableSquish works in markdown buffers only", vim.log.levels.WARN)
                return
            end

            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local row = 1
            local formatted = 0

            while row <= #lines do
                if is_table_like(lines[row]) then
                    local start_row = row
                    while row <= #lines and is_table_like(lines[row]) do
                        row = row + 1
                    end
                    local end_row = row - 1
                    if format_table_range(start_row, end_row, max_width) then
                        formatted = formatted + 1
                    end
                else
                    row = row + 1
                end
            end

            vim.notify("Markdown table squished for " .. formatted .. " table(s) at width " .. max_width, vim.log.levels.INFO)
        end

        vim.api.nvim_create_user_command("MarkdownTableSquish", function(cmd)
            local width = tonumber(cmd.args) or 28
            width = math.max(10, width)
            format_all_markdown_tables(width)
        end, {
            nargs = "?",
            desc = "Wrap long markdown table cells into multiline <br> entries for all tables",
        })

        vim.keymap.set("n", "<leader>mt", "<cmd>MarkdownTableSquish<cr>", {
            desc = "Squish markdown table cells",
            silent = true,
        })
    end,
}
