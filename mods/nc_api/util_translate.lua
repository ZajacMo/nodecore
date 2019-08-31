-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, table, type
    = ipairs, minetest, nodecore, pairs, table, type
local table_sort
    = table.sort
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local strings = {}
local strings_dirty

local token = "NodeCore"
local prefix = minetest.translate(modname, token)
prefix = prefix:sub(1, prefix:find(token) - 1)

function nodecore.translate_inform(str)
	if (not str) or (type(str) ~= "string") or (#str < 1)
	or (str:sub(1, #prefix) == prefix) then return end

	if not strings[str] then
		strings[str] = true
		strings_dirty = true
	end

	return true
end

function nodecore.translate(str, ...)
	if not nodecore.translate_inform(str) then return str end
	return minetest.translate(modname, str, ...)
end

minetest.register_globalstep(function()
		if not strings_dirty then return end
		strings_dirty = nil

		local keys = {}
		for k in pairs(strings) do keys[#keys + 1] = k end
		table_sort(keys)

		local data = "# textdomain: " .. modname .. "\n"
		for _, k in ipairs(keys) do
			data = data .. k .. "=" .. "\n"
		end

		local p = minetest.get_worldpath() .. "/" .. modname .. ".template.tr"
		return minetest.safe_file_write(p, data)
	end)
