-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, string, table, type
    = ipairs, minetest, nodecore, pairs, string, table, type
local string_format, string_match, table_sort
    = string.format, string.match, table.sort
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local strings = {}
local strings_dirty

local loadtimeover
minetest.register_on_mods_loaded(function() loadtimeover = true end)

local prefix = minetest.translate(modname, "x")
prefix = prefix:sub(1, prefix:find(modname) - 1)

function nodecore.translate_inform(str)
	if (not str) or (type(str) ~= "string") or (not string_match(str, "%S"))
	or (str:sub(1, #prefix) == prefix) then return end

	if not strings[str] then
		if loadtimeover then
			nodecore.log("warning", string_format(
					"Translation string informed late: %q",
					str))
		end
		strings[str] = true
		strings_dirty = true
	end

	return true
end

function nodecore.translate(str, ...)
	if not nodecore.translate_inform(str) then return str end
	return minetest.translate(modname, str, ...)
end

if nodecore.infodump() then
	nodecore.register_globalstep("translate templates", function()
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
end
