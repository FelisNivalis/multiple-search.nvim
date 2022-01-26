local M = {}

local match_priority = 0
local hl_colors = {}
local hl_name = 'MultipleSearchHlGroup'
-- TODO: set current_group's color to a different one
local current_group = 0
local matches = {}
local patterns = {}

function set_hl(_hl_colors)
	for i = 0, #_hl_colors-1 do
		vim.cmd('highlight ' .. hl_name .. i .. ' guibg=' .. _hl_colors[i+1])
	end
	for i = #_hl_colors, #hl_colors-1 do
		M.matchdelete({group=i})
		vim.cmd('highlight clear ' .. hl_name .. i)
	end
	if current_group >= #_hl_colors then
		current_group = 0
	end
	hl_colors = _hl_colors
end

function get_next_group_add()
	local n_groups = #hl_colors
	for i = 0, n_groups do
		if matches[(current_group + i) % n_groups] == nil then
			current_group = (current_group + i) % n_groups
			return current_group
		end
	end
	current_group = (current_group + 1) % n_groups
	M.matchdelete({})
	return current_group
end

function M.matchadd(options)
	-- TODO: support `magic`, `smartcase`, `ignorecase`
	local group = get_next_group_add()
	local m = {}
	local pattern = options.pattern
	for i = 1, vim.fn.winnr('$') do
		local win_id = vim.fn.win_getid(i)
	    m[win_id] = vim.fn.matchadd(
			hl_name .. group,
			pattern,
			match_priority,
			-1,
			{window = win_id}
		)
	end
	matches[group] = m
	patterns[group] = pattern
end

function M.matchdelete(options)
	-- TODO: accept multiple groups
	local group = options.group or current_group
	local match = matches[group]
	matches[group] = nil
	patterns[group] = nil
	for k, v in pairs(match or {}) do
		vim.fn.matchdelete(v, k)
	end
	-- M.next_matchgroup({})
end

function M.next_matchgroup(options)
	-- TODO: jump to match group
	-- TODO: support `-count`
	local d = 1
	if options.backward then
		d = -1
	end
	local n_groups = #hl_colors
	for i = 1, n_groups do
		local j = ((current_group + i * d) % n_groups + n_groups) % n_groups
		if matches[j] then
			current_group = j
			return
		end
	end
end

function M.next_match(options)
	-- TODO: support `-count`
	if patterns[current_group] then
		vim.fn.search(patterns[current_group], options.flags or '')
	end
end

function M.update_matches(options)
	local win_id
	if options.winnr ~= nil then
		win_id = vim.fn.win_getid(options.winnr)
	end
	if options.win_id ~= nil then
		win_id = options.win_id
	end
	if win_id == nil then
		win_id = vim.fn.win_getid()
	end
	for group, match in pairs(matches) do
		if match and match[win_id] == nil then
			match[win_id] = vim.fn.matchadd(
				hl_name .. group,
				patterns[group],
				match_priority,
				-1,
				{window = win_id}
			)
		end
	end
end

function M.setup(options)
	if options.match_priority then
		match_priority = options.match_priority
	end
	if options.colors and type(options.colors) == 'table' then
		set_hl(options.hl_colors)
	end
end

set_hl({
	"#aa0000",
	"#00aa00",
	"#0000aa",
	"#aaaa00",
	"#aa00aa",
	"#00bbbb",
	"#aaaaaa",
})

return M
